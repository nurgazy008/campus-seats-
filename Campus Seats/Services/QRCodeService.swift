//
//  QRCodeService.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import UIKit
import CoreImage

/// QR код құру сервисі
class QRCodeService {
    /// Singleton үлгісі - бір ғана дана
    static let shared = QRCodeService()
    
    /// Сырттан тікелей құруға болмайды
    private init() {}
    
    /// Мәтіннен QR код кескінін құрады
    func generateQRCode(from string: String, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        // Мәтінні UTF-8 дерекке айналдыру
        guard let data = string.data(using: .utf8) else { return nil }
        
        // QR код генераторын құру
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        // QR код мәтінін орнату
        filter.setValue(data, forKey: "inputMessage")
        // Жоғары түзету деңгейі (30% бұзылуға төзімді)
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        // Фильтрден кескін алу
        guard let ciImage = filter.outputImage else { return nil }
        // Масштабтау коэффициенттерін есептеу
        let scaleX = size.width / ciImage.extent.size.width
        let scaleY = size.height / ciImage.extent.size.height
        // Кескінді қажетті өлшемге кеңейту
        let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Core Image контекстін құру
        let context = CIContext()
        // CGImage алу
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return nil
        }
        
        // UIImage қайтару
        return UIImage(cgImage: cgImage)
    }
}



