//
//  QRCodeService.swift
//  Campus Seats
//
//  Created by Nurgazy Zhangozy on 08.12.2025.
//

import UIKit
import CoreImage

/// Сервис для генерации QR кодов
class QRCodeService {
    static let shared = QRCodeService()
    
    private init() {}
    
    /// Генерация QR кода из строки
    /// - Parameters:
    ///   - string: Текст для кодирования
    ///   - size: Размер изображения (по умолчанию 200x200)
    /// - Returns: UIImage с QR кодом или nil при ошибке
    func generateQRCode(from string: String, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage? {
        guard let data = string.data(using: .utf8) else { return nil }
        
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel") // Высокий уровень коррекции ошибок
        
        guard let ciImage = filter.outputImage else { return nil }
        
        // Масштабирование для лучшего качества
        let scaleX = size.width / ciImage.extent.size.width
        let scaleY = size.height / ciImage.extent.size.height
        let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(transformedImage, from: transformedImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
}



