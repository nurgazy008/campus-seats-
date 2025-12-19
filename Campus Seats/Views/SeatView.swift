//
//  SeatView.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import SwiftUI

/// Бір орынды көрсететін View
struct SeatView: View {
    /// Орын
    let seat: Seat
    /// Тапқанда орындалатын әрекет
    let onTap: () -> Void
    /// Ұзақ басқанда орындалатын әрекет
    let onLongPress: (() -> Void)?
    
    @State private var isPressed = false
    /// Масштаб коэффициенті
    @State private var scale: CGFloat = 1.0
    
    init(seat: Seat, onTap: @escaping () -> Void, onLongPress: (() -> Void)? = nil) {
        self.seat = seat
        self.onTap = onTap
        self.onLongPress = onLongPress
    }
    
    var body: some View {
        Button(action: {
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
            
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                scale = 0.85
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    scale = 1.0
                }
            }
            
            onTap()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(seatGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
                    .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                seat.isSelected ? Color.blue.opacity(0.3) : Color.clear,
                                lineWidth: seat.isSelected ? 2 : 0
                            )
                    )
                
                VStack(spacing: 2) {
                    Text(seat.seatNumber)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(textColor)
                    
                    if seat.isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.blue)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(seat.isOccupied)
        .scaleEffect(scale)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: scale)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: seat.isSelected)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.5)
                .onEnded { _ in
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    onLongPress?()
                }
        )
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                scale = pressing ? 0.9 : 1.0
            }
        }, perform: {})
    }
    
    /// Орын градиенті (күйіне байланысты)
    private var seatGradient: LinearGradient {
        if seat.isOccupied {
            return LinearGradient(
                colors: [.gray.opacity(0.4), .gray.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if seat.isSelected {
            return LinearGradient(
                colors: [.blue.opacity(0.5), .blue.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [.green.opacity(0.3), .green.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    /// Шек түсі (күйіне байланысты)
    private var borderColor: Color {
        if seat.isOccupied {
            return .gray.opacity(0.6)
        } else if seat.isSelected {
            return .blue
        } else {
            return .green.opacity(0.7)
        }
    }
    
    /// Шек ені
    private var borderWidth: CGFloat {
        seat.isSelected ? 3 : 1.5
    }
    
    /// Көлеңке түсі (күйіне байланысты)
    private var shadowColor: Color {
        if seat.isSelected {
            return .blue.opacity(0.4)
        } else if seat.isOccupied {
            return .clear
        } else {
            return .green.opacity(0.2)
        }
    }
    
    /// Көлеңке радиусы
    private var shadowRadius: CGFloat {
        seat.isSelected ? 8 : 4
    }
    
    /// Көлеңке офсеті
    private var shadowOffset: CGFloat {
        seat.isSelected ? 4 : 2
    }
    
    private var textColor: Color {
        if seat.isOccupied {
            return .gray.opacity(0.7)
        } else if seat.isSelected {
            return .blue
        } else {
            return .primary
        }
    }
}

#Preview {
    HStack {
        SeatView(seat: Seat(id: "1", row: 0, column: 0, isSelected: false, isOccupied: false)) {}
        SeatView(seat: Seat(id: "2", row: 0, column: 1, isSelected: true, isOccupied: false)) {}
        SeatView(seat: Seat(id: "3", row: 0, column: 2, isSelected: false, isOccupied: true)) {}
    }
    .padding()
}


