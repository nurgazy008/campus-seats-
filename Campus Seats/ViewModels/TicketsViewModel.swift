//
//  TicketsViewModel.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import Foundation
import SwiftUI

/// Билеттерді басқару үшін ViewModel
@MainActor
class TicketsViewModel: ObservableObject {
    /// Билеттер тізімі
    @Published var tickets: [Ticket] = []
    /// Жүктелу күйі
    @Published var isLoading = false
    
    /// Деректерді сақтау сервисі
    private let storageService = StorageService.shared
    
    init() {
        loadTickets()
    }
    
    /// Барлық билеттерді жүктеу
    func loadTickets() {
        isLoading = true
        tickets = storageService.loadAllTickets()
        isLoading = false
    }
    
    /// Билетті жою
    func deleteTicket(_ ticket: Ticket) {
        storageService.deleteTicket(ticket)
        loadTickets()
    }
    
    /// Билетті сақтау
    func saveTicket(event: Event, seatSelection: SeatSelection) {
        let ticket = Ticket(event: event, seatSelection: seatSelection)
        storageService.saveTicket(ticket)
        loadTickets()
    }
}


