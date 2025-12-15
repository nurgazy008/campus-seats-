//
//  SeatGridViewModel.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation
import SwiftUI

/// ViewModel для управления grid мест
@MainActor
class SeatGridViewModel: ObservableObject {
    @Published var seats: [Seat] = []
    @Published var selectedSeats: [Seat] = []
    @Published var seatSelection: SeatSelection?
    
    let event: Event
    private let storageService = StorageService.shared
    
    init(event: Event) {
        self.event = event
        generateSeats()
        loadSavedSelection()
        loadOccupiedSeats()
    }
    
    /// Генерация сетки мест
    private func generateSeats() {
        var generatedSeats: [Seat] = []
        
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
    
    /// Выбор/снятие выбора места (toggle)
    func selectSeat(_ seat: Seat) {
        // Валидация: нельзя выбрать занятое место
        guard !seat.isOccupied else {
            print("Ошибка: место занято")
            return
        }
        
        // Валидация: проверка существования места
        guard let index = seats.firstIndex(where: { $0.id == seat.id }) else {
            print("Ошибка: место не найдено")
            return
        }
        
        // Переключение выбора места
        if seats[index].isSelected {
            // Снимаем выбор
            seats[index].isSelected = false
            selectedSeats.removeAll { $0.id == seat.id }
        } else {
            // Добавляем выбор
            seats[index].isSelected = true
            if let updatedSeat = seats.first(where: { $0.id == seat.id }) {
                selectedSeats.append(updatedSeat)
            }
        }
        
        // Сохранение выбора
        saveSelection()
    }
    
    /// Очистка всех выбранных мест
    func clearSelection() {
        // Снимаем выбор со всех мест
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
    
    /// Сохранение выбора (без создания билета)
    private func saveSelection() {
        // Создаем массив выбранных мест
        let selectedSeatItems = selectedSeats.map { seat in
            SelectedSeat(seatId: seat.id, seatNumber: seat.seatNumber)
        }
        
        // Создаем или обновляем выбор
        if var existingSelection = seatSelection {
            existingSelection.selectedSeats = selectedSeatItems
            seatSelection = existingSelection
        } else {
            seatSelection = SeatSelection(eventId: event.id, selectedSeats: selectedSeatItems)
        }
        
        // Сохраняем только выбор (без билета)
        if let selection = seatSelection {
            storageService.saveSeatSelection(selection, for: event.id)
            print("💾 Сохранено \(selectedSeats.count) мест: \(selection.seatNumbers)")
        }
    }
    
    /// Бронирование мест (создание билета)
    func bookSeats() -> Bool {
        guard !selectedSeats.isEmpty else {
            print("❌ Нет выбранных мест для бронирования")
            return false
        }
        
        // Создаем массив выбранных мест
        let selectedSeatItems = selectedSeats.map { seat in
            SelectedSeat(seatId: seat.id, seatNumber: seat.seatNumber)
        }
        
        // Создаем выбор
        let selection = SeatSelection(eventId: event.id, selectedSeats: selectedSeatItems)
        seatSelection = selection
        
        // Сохраняем выбор
        storageService.saveSeatSelection(selection, for: event.id)
        
        // Создаем и сохраняем билет
        let ticket = Ticket(event: event, seatSelection: selection)
        storageService.saveTicket(ticket)
        
        print("🎫 Места забронированы: \(selection.seatNumbers)")
        return true
    }
    
    /// Загрузка сохраненного выбора
    private func loadSavedSelection() {
        guard let savedSelection = storageService.loadSeatSelection(for: event.id) else {
            print("ℹ️ Нет сохраненных мест для события \(event.id)")
            return
        }
        
        seatSelection = savedSelection
        
        // Восстановление всех выбранных мест
        var restoredCount = 0
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
    
    /// Переключение статуса занятости места
    func toggleOccupied(_ seat: Seat) {
        guard let index = seats.firstIndex(where: { $0.id == seat.id }) else { return }
        
        // Если место было выбрано, снимаем выбор
        if seats[index].isSelected {
            seats[index].isSelected = false
            selectedSeats.removeAll { $0.id == seat.id }
            saveSelection()
        }
        
        seats[index].isOccupied.toggle()
        
        // Сохраняем занятые места
        saveOccupiedSeats()
    }
    
    /// Сохранение занятых мест
    private func saveOccupiedSeats() {
        let occupiedSeatIds = seats.filter { $0.isOccupied }.map { $0.id }
        storageService.saveOccupiedSeats(occupiedSeatIds, for: event.id)
    }
    
    /// Загрузка занятых мест
    private func loadOccupiedSeats() {
        let occupiedSeatIds = storageService.loadOccupiedSeats(for: event.id)
        
        var restoredCount = 0
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
    
    /// Генерация QR кода для всех выбранных мест
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

/// Ошибки выбора места
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

/// Ошибки QR кода
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

