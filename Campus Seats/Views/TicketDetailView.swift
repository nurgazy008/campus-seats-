//
//  TicketDetailView.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import SwiftUI

/// Детальный вид билета с QR кодом
struct TicketDetailView: View {
    let ticket: Ticket
    @Environment(\.dismiss) var dismiss
    @State private var qrImage: UIImage?
    
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Информация о событии
                        VStack(alignment: .leading, spacing: 16) {
                            Text(ticket.eventName)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(icon: "calendar", text: ticket.formattedEventDate, color: .blue)
                                InfoRow(icon: "mappin.circle.fill", text: "Аудитория: \(ticket.room)", color: .red)
                                InfoRow(icon: "chair.fill", text: "Места: \(ticket.seatNumbers)", color: .green)
                                InfoRow(icon: "clock.fill", text: "Куплено: \(ticket.formattedPurchaseDate)", color: .orange)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .padding(.horizontal)
                        
                        // QR код
                        if let qrImage = qrImage {
                            VStack(spacing: 16) {
                                Text("QR код для входа")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Image(uiImage: qrImage)
                                    .resizable()
                                    .interpolation(.none)
                                    .scaledToFit()
                                    .frame(width: 280, height: 280)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white)
                                            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                                    )
                                
                                Text("Покажите этот QR код на входе")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Билет")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                generateQRCode()
            }
        }
    }
    
    private func generateQRCode() {
        qrImage = QRCodeService.shared.generateQRCode(
            from: ticket.qrData,
            size: CGSize(width: 300, height: 300)
        )
    }
}

#Preview {
    TicketDetailView(ticket: Ticket(
        event: EventViewModel.getDemoEvent(),
        seatSelection: SeatSelection(
            eventId: "event_001",
            selectedSeats: [
                SelectedSeat(seatId: "0_0", seatNumber: "A1"),
                SelectedSeat(seatId: "0_1", seatNumber: "A2")
            ]
        )
    ))
}

