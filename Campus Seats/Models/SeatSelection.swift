//
//  SeatSelection.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation

/// Таңдалған орын моделі
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

/// Оқиға үшін таңдалған орындар моделі
struct SeatSelection: Codable {
    let eventId: String
    var selectedSeats: [SelectedSeat] //орындар қосылып/алынуы мүмкін
    let timestamp: Date
    
    init(eventId: String, selectedSeats: [SelectedSeat] = []) {
        self.eventId = eventId
        self.selectedSeats = selectedSeats
        self.timestamp = Date()
    }
    
    /// QR код үшін деректер (барлық таңдалған орындар)
    var qrData: String {
        let seatsInfo = selectedSeats.map { "\($0.seatNumber)" }.joined(separator: ",")
        return "Event:\(eventId)|Seats:\(seatsInfo)|Time:\(timestamp.timeIntervalSince1970)"// уақытты санға
    }
    
    /// Орындар нөмірлерінің тізімі
    var seatNumbers: String {
        selectedSeats.map { $0.seatNumber }.joined(separator: ", ")
    }
}


