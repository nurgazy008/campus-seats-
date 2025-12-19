//
//  Ticket.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation

/// Билет моделі
struct Ticket: Identifiable, Codable {
    let id: String
    let eventId: String
    let eventName: String
    let eventDate: Date
    let room: String
    let selectedSeats: [SelectedSeat]
    let purchaseDate: Date
    
    init(event: Event, seatSelection: SeatSelection) {
        self.id = UUID().uuidString
        self.eventId = event.id
        self.eventName = event.name
        self.eventDate = event.date
        self.room = event.room
        self.selectedSeats = seatSelection.selectedSeats
        self.purchaseDate = Date()
    }
    
    /// Оқиғаның пішімделген күні
    var formattedEventDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: eventDate)
    }
    
    /// Сатып алудың пішімделген күні
    var formattedPurchaseDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: purchaseDate)// қысқаша формат мысаллы 15.12.2024
    }
    
    /// Орындар нөмірлері
    var seatNumbers: String {
        selectedSeats.map { $0.seatNumber }.joined(separator: ", ")
    }
    
    /// QR код үшін деректер
    var qrData: String {
        let seatsInfo = selectedSeats.map { "\($0.seatNumber)" }.joined(separator: ",")
        return "Event:\(eventId)|Seats:\(seatsInfo)|Time:\(purchaseDate.timeIntervalSince1970)"
    }
}

