//
//  EventViewModel.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation
import SwiftUI

/// Оқиғаларды басқару үшін ViewModel
@MainActor
class EventViewModel: ObservableObject {
    /// Оқиғалар тізімі
    @Published var events: [Event] = []
    /// Жүктелу күйі
    @Published var isLoading = false
    /// Қате хабарламасы
    @Published var errorMessage: String?
    
    init() {
        loadEvents()
    }
    
    /// Оқиғаларды жүктеу (демо деректермен)
    func loadEvents() {
        isLoading = true
        errorMessage = nil
        
        // Деректерді жүктеуді имитациялау (нақты қосымшада мұнда API сұрауы болады)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            do {
                let demoEvents = Self.getDemoEvents()
                try self?.validateEvents(demoEvents)
                self?.events = demoEvents
                self?.isLoading = false
            } catch {
                self?.errorMessage = error.localizedDescription
                self?.isLoading = false
            }
        }
    }
    
    /// Оқиғаларды валидациялау
    private func validateEvents(_ events: [Event]) throws {
        // Тізім бос емес екенін тексеру
        guard !events.isEmpty else {
            throw EventError.emptyEvents
        }
        
        // Әр оқиғаны тексеру
        for event in events {
            // Орындар конфигурациясын тексеру
            guard event.totalRows > 0 && event.totalColumns > 0 else {
                throw EventError.invalidSeatConfiguration
            }
            
            // Оқиға атауын тексеру
            guard !event.name.isEmpty else {
                throw EventError.invalidEventName
            }
        }
    }
    
    /// Демо-оқиғалар тізімін алу
    static func getDemoEvents() -> [Event] {
        let calendar = Calendar.current
        let now = Date()
        
        return [
            Event(
                id: "event_001",
                name: "Лекция по iOS разработке",
                date: now,
                room: "Аудитория 101",
                totalRows: 5,
                totalColumns: 6
            ),
            Event(
                id: "event_002",
                name: "Семинар по SwiftUI",
                date: calendar.date(byAdding: .day, value: 1, to: now) ?? now,
                room: "Аудитория 205",
                totalRows: 4,
                totalColumns: 5
            ),
            Event(
                id: "event_003",
                name: "Практика по архитектуре",
                date: calendar.date(byAdding: .day, value: 2, to: now) ?? now,
                room: "Аудитория 310",
                totalRows: 6,
                totalColumns: 7
            ),
            Event(
                id: "event_004",
                name: "Экзамен по мобильной разработке",
                date: calendar.date(byAdding: .day, value: 3, to: now) ?? now,
                room: "Аудитория 150",
                totalRows: 8,
                totalColumns: 10
            )
        ]
    }
    
    /// ID бойынша оқиғаны алу
    func getEvent(by id: String) -> Event? {
        events.first { $0.id == id }
    }
    
    /// Preview үшін бір демо-оқиғаны алу
    static func getDemoEvent() -> Event {
        getDemoEvents().first ?? Event(
            id: "event_001",
            name: "Лекция по iOS разработке",
            date: Date(),
            room: "Аудитория 101",
            totalRows: 5,
            totalColumns: 6
        )
    }
}

/// Оқиғалар қателері
enum EventError: LocalizedError {
    case emptyEvents
    case invalidSeatConfiguration
    case invalidEventName
    
    var errorDescription: String? {
        switch self {
        case .emptyEvents:
            return "Қолжетімді оқиғалар жоқ"
        case .invalidSeatConfiguration:
            return "Орындар конфигурациясы дұрыс емес"
        case .invalidEventName:
            return "Оқиға атауы дұрыс емес"
        }
    }
}


