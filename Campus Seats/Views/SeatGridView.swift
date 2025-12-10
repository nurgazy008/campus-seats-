//
//  SeatGridView.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import SwiftUI

/// Основной вид с grid мест
struct SeatGridView: View {
    @StateObject private var viewModel: SeatGridViewModel
    @State private var showQRCode = false
    
    init(event: Event) {
        _viewModel = StateObject(wrappedValue: SeatGridViewModel(event: event))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Информация о событии
                EventInfoView(event: viewModel.event, selectedSeats: viewModel.selectedSeats)
                
                // Легенда
                legendView
                
                // Grid мест
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: viewModel.event.totalColumns), spacing: 8) {
                    ForEach(viewModel.seats) { seat in
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
                    }
                }
                .padding(.horizontal)
                
                // Кнопки действий
                if !viewModel.selectedSeats.isEmpty {
                    VStack(spacing: 16) {
                        // Кнопка бронирования
                        Button(action: {
                            // Бронируем места
                            if viewModel.bookSeats() {
                                // Показываем QR код после бронирования
                                showQRCode = true
                                
                                // Тактильная обратная связь
                                let impact = UIImpactFeedbackGenerator(style: .medium)
                                impact.impactOccurred()
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
                        
                        // Кнопка очистки выбора
                        Button(action: {
                            withAnimation {
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
                
                // Подсказки
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


