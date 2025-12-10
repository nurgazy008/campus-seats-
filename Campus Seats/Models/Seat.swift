//
//  Seat.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation

/// Модель места в аудитории
struct Seat: Identifiable, Codable, Equatable {
    let id: String
    let row: Int
    let column: Int
    var isSelected: Bool = false
    var isOccupied: Bool = false
    
    /// Уникальный номер места (например, "A1", "B3")
    var seatNumber: String {
        let rowLetter = String(Character(UnicodeScalar(65 + row)!)) // A, B, C...
        return "\(rowLetter)\(column + 1)"
    }
}


