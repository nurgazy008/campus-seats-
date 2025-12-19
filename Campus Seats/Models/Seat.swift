//
//  Seat.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation

/// Аудиториядағы орын моделі
struct Seat: Identifiable, Codable, Equatable {//id қасиеті бар, json түрлендіруге болады, екі орынды салыстыруға
    let id: String
    let row: Int
    let column: Int
    var isSelected: Bool = false
    var isOccupied: Bool = false // орын боспа
    
    /// Орынның бірегей нөмірі (мысалы, "A1", "B3")
    var seatNumber: String {
        let rowLetter = String(Character(UnicodeScalar(65 + row)!)) // A, B, C...
        return "\(rowLetter)\(column + 1)"
    }
}
/// row --> A
/// column --> int


