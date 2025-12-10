//
//  StorageService.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation

/// Сервис для сохранения и загрузки данных
class StorageService {
    static let shared = StorageService()
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    private let selectedSeatKey = "selectedSeat_"
    
    /// Сохранить выбранные места для события
    func saveSeatSelection(_ selection: SeatSelection, for eventId: String) {
        let key = selectedSeatKey + eventId
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(selection) {
            userDefaults.set(encoded, forKey: key)
            userDefaults.synchronize() // Принудительная синхронизация
            print("✅ Сохранено мест: \(selection.selectedSeats.count) для события \(eventId)")
        } else {
            print("❌ Ошибка сохранения мест")
        }
    }
    
    /// Загрузить выбранные места для события
    func loadSeatSelection(for eventId: String) -> SeatSelection? {
        let key = selectedSeatKey + eventId
        guard let data = userDefaults.data(forKey: key) else {
            print("ℹ️ Нет сохраненных данных для события \(eventId)")
            return nil
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let selection = try? decoder.decode(SeatSelection.self, from: data) {
            print("✅ Загружено мест: \(selection.selectedSeats.count) для события \(eventId)")
            return selection
        } else {
            print("❌ Ошибка декодирования данных")
            return nil
        }
    }
    
    /// Удалить выбранное место для события
    func removeSeatSelection(for eventId: String) {
        let key = selectedSeatKey + eventId
        userDefaults.removeObject(forKey: key)
    }
    
    // MARK: - Билеты
    
    private let ticketsKey = "savedTickets"
    
    /// Сохранить билет
    func saveTicket(_ ticket: Ticket) {
        var tickets = loadAllTickets()
        // Удаляем старый билет для этого события, если есть
        tickets.removeAll { $0.eventId == ticket.eventId }
        // Добавляем новый
        tickets.append(ticket)
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(tickets) {
            userDefaults.set(encoded, forKey: ticketsKey)
            userDefaults.synchronize()
            print("✅ Билет сохранен: \(ticket.eventName)")
        } else {
            print("❌ Ошибка сохранения билета")
        }
    }
    
    /// Загрузить все билеты
    func loadAllTickets() -> [Ticket] {
        guard let data = userDefaults.data(forKey: ticketsKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let tickets = try? decoder.decode([Ticket].self, from: data) {
            return tickets.sorted { $0.eventDate > $1.eventDate } // Сортировка по дате (новые сверху)
        }
        return []
    }
    
    /// Удалить билет
    func deleteTicket(_ ticket: Ticket) {
        var tickets = loadAllTickets()
        tickets.removeAll { $0.id == ticket.id }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(tickets) {
            userDefaults.set(encoded, forKey: ticketsKey)
            userDefaults.synchronize()
            print("✅ Билет удален")
        }
    }
}


