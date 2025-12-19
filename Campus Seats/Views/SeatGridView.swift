//
//  SeatGridView.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import SwiftUI

/// Орындар торын көрсететін View
struct SeatGridView: View {
    /// Орындар торы ViewModel
    @StateObject private var viewModel: SeatGridViewModel
    /// QR код экранын көрсету күйі
    @State private var showQRCode = false
    
    init(event: Event) {
        _viewModel = StateObject(wrappedValue: SeatGridViewModel(event: event))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                EventInfoView(event: viewModel.event, selectedSeats: viewModel.selectedSeats)
                
                legendView
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: viewModel.event.totalColumns), spacing: 8) {
                    ForEach(Array(viewModel.seats.enumerated()), id: \.element.id) { index, seat in
                        SeatView(
                            seat: seat,
                            onTap: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.selectSeat(seat)
                                }
                            },
                            onLongPress: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.toggleOccupied(seat)
                                }
                            }
                        )
                        .aspectRatio(1, contentMode: .fit)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.01), value: viewModel.seats.count)
                    }
                }
                .padding(.horizontal)
                
                if !viewModel.selectedSeats.isEmpty {
                    VStack(spacing: 16) {
                        Button(action: {
                            if viewModel.bookSeats() {
                                let notification = UINotificationFeedbackGenerator()
                                notification.notificationOccurred(.success)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    showQRCode = true
                                }
                            } else {
                                let notification = UINotificationFeedbackGenerator()
                                notification.notificationOccurred(.error)
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title3)
                                Text("Забронировать места (\(viewModel.selectedSeats.count))")
                                    .fontWeight(.semibold)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: .green.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.clearSelection()
                            }
                        }) {
                            HStack {
                                Image(systemName: "xmark.circle")
                                Text("Очистить выбор")
                            }
                            .font(.subheadline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                
                VStack(spacing: 4) {
                    Text("💡 Тап по месту - выбрать/снять выбор")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("💡 Долгое нажатие - отметить как занятое")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom)
            }
        }
        .navigationTitle("Выбор места")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showQRCode) {
            if let qrImage = viewModel.generateQRCode(),
               let selection = viewModel.seatSelection {
                QRCodeView(
                    qrImage: qrImage,
                    seatNumbers: selection.seatNumbers,
                    count: viewModel.selectedSeats.count
                )
            }
        }
    }
    
    /// Легенда (орын күйлерін түсіндіру)
    private var legendView: some View {
        VStack(spacing: 12) {
            Text("Легенда")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            HStack(spacing: 20) {
                legendItem(
                    gradient: LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    borderColor: .green.opacity(0.7),
                    text: "Свободно"
                )
                legendItem(
                    gradient: LinearGradient(colors: [.blue.opacity(0.5), .blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    borderColor: .blue,
                    text: "Выбрано"
                )
                legendItem(
                    gradient: LinearGradient(colors: [.gray.opacity(0.4), .gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    borderColor: .gray.opacity(0.6),
                    text: "Занято"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
    
    /// Легенда элементі
    private func legendItem(gradient: LinearGradient, borderColor: Color, text: String) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 6)
                .fill(gradient)
                .frame(width: 24, height: 24)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(borderColor, lineWidth: 1.5)
                )
            Text(text)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationStack {
        SeatGridView(event: EventViewModel.getDemoEvent())
    }
}


