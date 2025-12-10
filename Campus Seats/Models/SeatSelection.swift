//
//  SeatSelection.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation

/// Модель выбранного места
struct SelectedSeat: Codable, Identifiable {
    let id: String
    let seatId: String
    let seatNumber: String
    let timestamp: Date
    
    init(seatId: String, seatNumber: String) {
        self.id = UUID().uuidString
        self.seatId = seatId
        self.seatNumber = seatNumber
        self.timestamp = Date()
    }
}

/// Модель выбранных мест для события
struct SeatSelection: Codable {
    let eventId: String
    var selectedSeats: [SelectedSeat]
    let timestamp: Date
    
    init(eventId: String, selectedSeats: [SelectedSeat] = []) {
        self.eventId = eventId
        self.selectedSeats = selectedSeats
        self.timestamp = Date()
    }
    
    /// Данные для QR кода (все выбранные места)
    var qrData: String {
        let seatsInfo = selectedSeats.map { "\($0.seatNumber)" }.joined(separator: ",")
        return "Event:\(eventId)|Seats:\(seatsInfo)|Time:\(timestamp.timeIntervalSince1970)"
    }
    
    /// Список номеров мест
    var seatNumbers: String {
        selectedSeats.map { $0.seatNumber }.joined(separator: ", ")
    }
}


