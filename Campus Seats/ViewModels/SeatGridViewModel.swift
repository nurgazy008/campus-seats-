//
//  SeatGridViewModel.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation
import SwiftUI

/// Орындар торын басқару үшін ViewModel
@MainActor
class SeatGridViewModel: ObservableObject {
    /// Барлық орындар тізімі
    @Published var seats: [Seat] = []
    /// Таңдалған орындар тізімі
    @Published var selectedSeats: [Seat] = []
    /// Орын таңдау объектісі
    @Published var seatSelection: SeatSelection?
    
    /// Оқиға
    let event: Event
    /// Деректерді сақтау сервисі
    private let storageService = StorageService.shared
    
    init(event: Event) {
        self.event = event
        generateSeats()
        loadSavedSelection()
        loadOccupiedSeats()
    }
    
    /// Орындар торын генерациялау
    private func generateSeats() {
        var generatedSeats: [Seat] = []
        
        // Қатарлар мен бағандар бойынша орындар құру
        for row in 0..<event.totalRows {
            for column in 0..<event.totalColumns {
                let seat = Seat(
                    id: "\(row)_\(column)",
                    row: row,
                    column: column,
                    isSelected: false,
                    isOccupied: false
                )
                generatedSeats.append(seat)
            }
        }
        
        self.seats = generatedSeats
    }
    
    /// Орынды таңдау/таңдаудан алып тастау
    func selectSeat(_ seat: Seat) {
        // Бос емес орынды тексеру
        guard !seat.isOccupied else {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.warning)
            print("Ошибка: место занято")
            return
        }
        
        guard let index = seats.firstIndex(where: { $0.id == seat.id }) else {
            print("Ошибка: место не найдено")
            return
        }
        
        // Таңдау күйін ауыстыру
        if seats[index].isSelected {
            seats[index].isSelected = false
            selectedSeats.removeAll { $0.id == seat.id }
        } else {
            seats[index].isSelected = true
            if let updatedSeat = seats.first(where: { $0.id == seat.id }) {
                selectedSeats.append(updatedSeat)
            }
        }
        
        saveSelection()
    }
    
    /// Барлық таңдауларды тазалау
    func clearSelection() {
        for selectedSeat in selectedSeats {
            if let index = seats.firstIndex(where: { $0.id == selectedSeat.id }) {
                seats[index].isSelected = false
            }
        }
        
        selectedSeats.removeAll()
        seatSelection = nil
        storageService.removeSeatSelection(for: event.id)
        print("✅ Все места очищены")
    }
    
    /// Таңдалған орындарды сақтау
    private func saveSelection() {
        let selectedSeatItems = selectedSeats.map { seat in
            SelectedSeat(seatId: seat.id, seatNumber: seat.seatNumber)
        }
        
        // Мәнін жаңарту немесе жаңа құру
        if var existingSelection = seatSelection {
            existingSelection.selectedSeats = selectedSeatItems
            seatSelection = existingSelection
        } else {
            seatSelection = SeatSelection(eventId: event.id, selectedSeats: selectedSeatItems)
        }
        
        if let selection = seatSelection {
            storageService.saveSeatSelection(selection, for: event.id)
            print("💾 Сохранено \(selectedSeats.count) мест: \(selection.seatNumbers)")
        }
    }
    
    /// Таңдалған орындарды брондау (билет құру)
    func bookSeats() -> Bool {
        guard !selectedSeats.isEmpty else {
            print("❌ Нет выбранных мест для бронирования")
            return false
        }
        
        let selectedSeatItems = selectedSeats.map { seat in
            SelectedSeat(seatId: seat.id, seatNumber: seat.seatNumber)
        }
        
        let selection = SeatSelection(eventId: event.id, selectedSeats: selectedSeatItems)
        seatSelection = selection
        
        storageService.saveSeatSelection(selection, for: event.id)
        
        // Билет құру және сақтау
        let ticket = Ticket(event: event, seatSelection: selection)
        storageService.saveTicket(ticket)
        
        print("🎫 Места забронированы: \(selection.seatNumbers)")
        return true
    }
    
    /// Сақталған таңдауларды жүктеу
    private func loadSavedSelection() {
        guard let savedSelection = storageService.loadSeatSelection(for: event.id) else {
            print("ℹ️ Нет сохраненных мест для события \(event.id)")
            return
        }
        
        seatSelection = savedSelection
        var restoredCount = 0
        // Сақталған орындарды қалпына келтіру
        for selectedSeatItem in savedSelection.selectedSeats {
            if let index = seats.firstIndex(where: { $0.id == selectedSeatItem.seatId }) {
                seats[index].isSelected = true
                if let seat = seats.first(where: { $0.id == selectedSeatItem.seatId }) {
                    if !selectedSeats.contains(where: { $0.id == seat.id }) {
                        selectedSeats.append(seat)
                        restoredCount += 1
                    }
                }
            } else {
                print("⚠️ Место \(selectedSeatItem.seatId) не найдено в сетке")
            }
        }
        
        print("✅ Восстановлено \(restoredCount) из \(savedSelection.selectedSeats.count) сохраненных мест")
    }
    
    /// Орынның бос емес күйін ауыстыру
    func toggleOccupied(_ seat: Seat) {
        guard let index = seats.firstIndex(where: { $0.id == seat.id }) else { return }
        
        // Егер орын таңдалған болса, таңдаудан алып тастау
        if seats[index].isSelected {
            seats[index].isSelected = false
            selectedSeats.removeAll { $0.id == seat.id }
            saveSelection()
        }
        
        // Бос емес күйін ауыстыру
        seats[index].isOccupied.toggle()
        
        saveOccupiedSeats()
    }
    
    /// Бос емес орындарды сақтау
    private func saveOccupiedSeats() {
        let occupiedSeatIds = seats.filter { $0.isOccupied }.map { $0.id }
        storageService.saveOccupiedSeats(occupiedSeatIds, for: event.id)
    }
    
    /// Бос емес орындарды жүктеу
    private func loadOccupiedSeats() {
        let occupiedSeatIds = storageService.loadOccupiedSeats(for: event.id)
        
        var restoredCount = 0
        // Бос емес орындарды қалпына келтіру
        for seatId in occupiedSeatIds {
            if let index = seats.firstIndex(where: { $0.id == seatId }) {
                seats[index].isOccupied = true
                restoredCount += 1
            } else {
                print("⚠️ Занятое место \(seatId) не найдено в сетке")
            }
        }
        
        if restoredCount > 0 {
            print("✅ Восстановлено \(restoredCount) занятых мест")
        }
    }
    
    /// QR код құру
    func generateQRCode() -> UIImage? {
        guard let selection = seatSelection, !selection.selectedSeats.isEmpty else {
            print("Ошибка: не выбрано ни одного места")
            return nil
        }
        
        guard let qrImage = QRCodeService.shared.generateQRCode(
            from: selection.qrData,
            size: CGSize(width: 300, height: 300)
        ) else {
            print("Ошибка: не удалось сгенерировать QR код")
            return nil
        }
        
        return qrImage
    }
}

enum SeatError: LocalizedError {
    case seatOccupied
    case seatNotFound
    
    var errorDescription: String? {
        switch self {
        case .seatOccupied:
            return "Это место уже занято"
        case .seatNotFound:
            return "Место не найдено"
        }
    }
}

enum QRCodeError: LocalizedError {
    case noSelection
    case generationFailed
    
    var errorDescription: String? {
        switch self {
        case .noSelection:
            return "Не выбрано место"
        case .generationFailed:
            return "Не удалось сгенерировать QR код"
        }
    }
}

