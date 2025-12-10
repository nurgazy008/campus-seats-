//
//  MyTicketsView.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import SwiftUI

/// Экран "Мои билеты"
struct MyTicketsView: View {
    @StateObject private var viewModel = TicketsViewModel()
    @State private var selectedTicket: Ticket?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Градиентный фон
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Загрузка билетов...")
                } else if viewModel.tickets.isEmpty {
                    EmptyTicketsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.tickets) { ticket in
                                TicketCardView(ticket: ticket) {
                                    selectedTicket = ticket
                                }
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Мои билеты")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                viewModel.loadTickets()
            }
            .sheet(item: $selectedTicket) { ticket in
                TicketDetailView(ticket: ticket)
            }
        }
    }
}

/// Карточка билета
struct TicketCardView: View {
    let ticket: Ticket
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(ticket.eventName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Бейдж "Забронировано"
                            Text("Забронировано")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.green)
                                )
                        }
                        
                        HStack(spacing: 16) {
                            Label(ticket.formattedEventDate, systemImage: "calendar")
                            Label(ticket.room, systemImage: "mappin.circle")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "chair.fill")
                                .foregroundColor(.blue)
                            Text("Места: \(ticket.seatNumbers)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.top, 4)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "qrcode")
                            .font(.title)
                            .foregroundColor(.blue)
                        Text("\(ticket.selectedSeats.count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Куплено: \(ticket.formattedPurchaseDate)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Показать QR")
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

/// Пустой список билетов
struct EmptyTicketsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "ticket.fill")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Нет билетов")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Выберите места на событиях, чтобы они появились здесь")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

#Preview {
    MyTicketsView()
}

