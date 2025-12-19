//
//  QRCodeView.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import SwiftUI

/// QR код көрсететін View
struct QRCodeView: View {
    /// QR код кескіні
    let qrImage: UIImage
    /// Орындар нөмірлері
    let seatNumbers: String
    /// Орындар саны
    let count: Int
    /// Жабу функциясы
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                                .symbolEffect(.bounce, value: count)
                            
                            Text("Места забронированы!")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                            
                            Text("Ваш билет сохранен в 'Мои билеты'")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                        Image(uiImage: qrImage)
                            .resizable()
                            .interpolation(.none)
                            .scaledToFit()
                            .frame(width: 280, height: 280)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white, Color.white.opacity(0.95)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                            )
                            .padding()
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: qrImage)
                        
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "chair.fill")
                                    .foregroundColor(.blue)
                                Text(count == 1 ? "Место: \(seatNumbers)" : "Места (\(count)): \(seatNumbers)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                            }
                            
                            Text("Покажите этот QR код на входе")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        let impact = UIImpactFeedbackGenerator(style: .light)
                        impact.impactOccurred()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                            Text("Закрыть")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("QR код")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }
        }
    }
}

#Preview {
    if let qrImage = QRCodeService.shared.generateQRCode(from: "Test QR Code") {
        QRCodeView(qrImage: qrImage, seatNumbers: "A1, A2, B3", count: 3)
    }
}


