//
//  Event.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation

/// Оқиға/лекция моделі
struct Event: Identifiable, Codable {
    let id: String // id
    let name: String // event атауы
    let date: Date // күні мен уақыты
    let room: String // аудитория
    let totalRows: Int // қатарлар саны
    let totalColumns: Int //жалпы орындар саны
    
    /// Жалпы орындар саны
    var totalSeats: Int {
        totalRows * totalColumns
    }
    
    /// Пішімделген күн
    var formattedDate: String {
        let formatter = DateFormatter() // date оқылатын мәтінге айналдырады
        formatter.dateStyle = .medium // 15 дек 2024
        formatter.timeStyle = .short // 14:30
        formatter.locale = Locale(identifier: "ru_RU") // орысшаға
        return formatter.string(from: date)
    }
}



