//
//  Event.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation

/// Модель события/лекции
struct Event: Identifiable, Codable {
    let id: String
    let name: String
    let date: Date
    let room: String
    let totalRows: Int
    let totalColumns: Int
    
    /// Общее количество мест
    var totalSeats: Int {
        totalRows * totalColumns
    }
    
    /// Форматированная дата
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}


