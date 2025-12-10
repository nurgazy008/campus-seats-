//
//  EventInfoView.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import SwiftUI

/// Вид с информацией о событии
struct EventInfoView: View {
    let event: Event
    let selectedSeats: [Seat]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(event.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 10) {
                InfoRow(icon: "calendar", text: event.formattedDate, color: .blue)
                InfoRow(icon: "mappin.circle.fill", text: "Аудитория: \(event.room)", color: .red)
                InfoRow(icon: "chair.fill", text: "Всего мест: \(event.totalSeats)", color: .green)
            }
            
            if !selectedSeats.isEmpty {
                Divider()
                    .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Выбрано мест: \(selectedSeats.count)")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            Text("Нажмите 'Забронировать' для подтверждения")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.headline)
                    
                    // Список выбранных мест
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(selectedSeats) { seat in
                                Text(seat.seatNumber)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.blue.opacity(0.15))
                                    )
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color(.systemGray6), Color(.systemGray6).opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

/// Строка информации
struct InfoRow: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    EventInfoView(
        event: EventViewModel.getDemoEvent(),
        selectedSeats: [
            Seat(id: "1", row: 0, column: 0, isSelected: true, isOccupied: false),
            Seat(id: "2", row: 0, column: 1, isSelected: true, isOccupied: false)
        ]
    )
}


