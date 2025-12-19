//
//  StorageService.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation

/// Деректерді сақтау және жүктеу сервисі
class StorageService {
    /// Singleton үлгісі - бір ғана дана
    static let shared = StorageService()
    /// UserDefaults - деректерді сақтау үшін
    private let userDefaults = UserDefaults.standard
    
    /// Сырттан тікелей құруға болмайды
    private init() {}
    
    // MARK: - Орын таңдауларды сақтау/жүктеу
    
    /// Орын таңдаулар үшін кілт префиксі
    private let selectedSeatKey = "selectedSeat_"
    
    /// Оқиға үшін таңдалған орындарды сақтайды
    func saveSeatSelection(_ selection: SeatSelection, for eventId: String) {
        let key = selectedSeatKey + eventId
        let encoder = JSONEncoder()
        // Күндерді ISO8601 форматта сақтау
        encoder.dateEncodingStrategy = .iso8601
        if let encoded = try? encoder.encode(selection) {
            userDefaults.set(encoded, forKey: key)
            userDefaults.synchronize()
            print("✅ Сохранено мест: \(selection.selectedSeats.count) для события \(eventId)")
        } else {
            print("❌ Ошибка сохранения мест")
        }
    }
    
    /// Оқиға үшін сақталған орын таңдауларды жүктейді
    func loadSeatSelection(for eventId: String) -> SeatSelection? {
        let key = selectedSeatKey + eventId
        guard let data = userDefaults.data(forKey: key) else {
            print("ℹ️ Нет сохраненных данных для события \(eventId)")
            return nil
        }
        
        let decoder = JSONDecoder()
        // Күндерді ISO8601 форматтан оқу
        decoder.dateDecodingStrategy = .iso8601
        
        if let selection = try? decoder.decode(SeatSelection.self, from: data) {
            print("✅ Загружено мест: \(selection.selectedSeats.count) для события \(eventId)")
            return selection
        } else {
            print("❌ Ошибка декодирования данных")
            return nil
        }
    }
    
    /// Оқиға үшін сақталған орын таңдауларды жояды
    func removeSeatSelection(for eventId: String) {
        let key = selectedSeatKey + eventId
        userDefaults.removeObject(forKey: key)
    }
    
    // MARK: - Бос емес орындарды сақтау/жүктеу
    
    /// Бос емес орындар үшін кілт префиксі
    private let occupiedSeatsKey = "occupiedSeats_"
    
    /// Оқиға үшін бос емес орындар ID-лерін сақтайды
    func saveOccupiedSeats(_ seatIds: [String], for eventId: String) {
        let key = occupiedSeatsKey + eventId
        userDefaults.set(seatIds, forKey: key)
        userDefaults.synchronize()
        print("✅ Сохранено \(seatIds.count) занятых мест для события \(eventId)")
    }
    
    /// Оқиға үшін бос емес орындар ID-лерін жүктейді
    func loadOccupiedSeats(for eventId: String) -> [String] {
        let key = occupiedSeatsKey + eventId
        guard let seatIds = userDefaults.array(forKey: key) as? [String] else {
            print("ℹ️ Нет сохраненных занятых мест для события \(eventId)")
            return []
        }
        print("✅ Загружено \(seatIds.count) занятых мест для события \(eventId)")
        return seatIds
    }
    
    /// Оқиға үшін бос емес орындар деректерін жояды
    func removeOccupiedSeats(for eventId: String) {
        let key = occupiedSeatsKey + eventId
        userDefaults.removeObject(forKey: key)
        print("✅ Удалены занятые места для события \(eventId)")
    }
    
    // MARK: - Билеттерді сақтау/жүктеу/жою
    
    /// Билеттер үшін кілт
    private let ticketsKey = "savedTickets"
    
    /// Билетті сақтайды (егер сол оқиға үшін билет бар болса, оны ауыстырады)
    func saveTicket(_ ticket: Ticket) {
        var tickets = loadAllTickets()
        // Сол оқиға үшін ескі билетті жою
        tickets.removeAll { $0.eventId == ticket.eventId }
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
    
    /// Барлық сақталған билеттерді жүктейді (оқиға күні бойынша сұрыпталған)
    func loadAllTickets() -> [Ticket] {
        guard let data = userDefaults.data(forKey: ticketsKey) else {
            return []
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let tickets = try? decoder.decode([Ticket].self, from: data) {
            // Оқиға күні бойынша кему ретімен сұрыптау
            return tickets.sorted { $0.eventDate > $1.eventDate }
        }
        return []
    }
    
    /// Билетті жояды
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


