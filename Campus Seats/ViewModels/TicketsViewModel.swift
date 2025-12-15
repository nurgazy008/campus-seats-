//
//  TicketsViewModel.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation
import SwiftUI

/// ViewModel для управления билетами
@MainActor
class TicketsViewModel: ObservableObject {
    @Published var tickets: [Ticket] = []
    @Published var isLoading = false
    
    private let storageService = StorageService.shared
    
    init() {
        loadTickets()
    }
    
    /// Загрузка билетов
    func loadTickets() {
        isLoading = true
        tickets = storageService.loadAllTickets()
        isLoading = false
    }
    
    /// Удалить билет
    func deleteTicket(_ ticket: Ticket) {
        storageService.deleteTicket(ticket)
        loadTickets()
    }
    
    /// Сохранить билет (вызывается при выборе мест)
    func saveTicket(event: Event, seatSelection: SeatSelection) {
        let ticket = Ticket(event: event, seatSelection: seatSelection)
        storageService.saveTicket(ticket)
        loadTickets()
    }
}


