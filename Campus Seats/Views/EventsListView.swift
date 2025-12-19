//
//  EventsListView.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import SwiftUI

/// Оқиғалар тізімін көрсететін View
struct EventsListView: View {
    /// Оқиғалар ViewModel
    @StateObject private var viewModel = EventViewModel()
    /// Таңдалған оқиға
    @State private var selectedEvent: Event?
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if viewModel.isLoading {
                    ProgressView("Загрузка событий...")
                        .scaleEffect(1.5)
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        viewModel.loadEvents()
                    }
                } else if viewModel.events.isEmpty {
                    EmptyEventsView()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(viewModel.events.enumerated()), id: \.element.id) { index, event in
                                EventCardView(event: event) {
                                    selectedEvent = event
                                }
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                                .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.05), value: viewModel.events.count)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Campus Seats")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedEvent) { event in
                NavigationStack {
                    SeatGridView(event: event)
                }
            }
            .refreshable {
                viewModel.loadEvents()
            }
        }
    }
}

/// Оқиға карточкасы компоненті
struct EventCardView: View {
    /// Оқиға
    let event: Event
    /// Тапқанда орындалатын әрекет
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            onTap()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            Label(event.formattedDate, systemImage: "calendar")
                            Label(event.room, systemImage: "mappin.circle")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 4) {
                        Image(systemName: "chair.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                        Text("\(event.totalSeats)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Spacer()
                    Text("Выбрать место →")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

/// Бос оқиғалар экраны
struct EmptyEventsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("Нет доступных событий")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("События появятся здесь, когда они будут доступны")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

/// Қате экраны
struct ErrorView: View {
    /// Қате хабарламасы
    let message: String
    /// Қайталау функциясы
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Ошибка")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                onRetry()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Повторить")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
    }
}

/// Басылғанда масштабталатын батырма стилі
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    EventsListView()
}
