//
//  EventViewModel.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation
import SwiftUI

/// ViewModel для управления событиями
@MainActor
class EventViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        loadEvents()
    }
    
    /// Загрузка событий
    func loadEvents() {
        isLoading = true
        errorMessage = nil
        
        // Имитация загрузки данных (в реальном приложении здесь будет API запрос)
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
    
    /// Валидация событий
    private func validateEvents(_ events: [Event]) throws {
        guard !events.isEmpty else {
            throw EventError.emptyEvents
        }
        
        for event in events {
            guard event.totalRows > 0 && event.totalColumns > 0 else {
                throw EventError.invalidSeatConfiguration
            }
            
            guard !event.name.isEmpty else {
                throw EventError.invalidEventName
            }
        }
    }
    
    /// Получить список демо-событий
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
    
    /// Получить событие по ID
    func getEvent(by id: String) -> Event? {
        events.first { $0.id == id }
    }
    
    /// Получить одно демо-событие для preview
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

/// Ошибки событий
enum EventError: LocalizedError {
    case emptyEvents
    case invalidSeatConfiguration
    case invalidEventName
    
    var errorDescription: String? {
        switch self {
        case .emptyEvents:
            return "Нет доступных событий"
        case .invalidSeatConfiguration:
            return "Неверная конфигурация мест"
        case .invalidEventName:
            return "Неверное название события"
        }
    }
}


