//
//  DeviceType.swift
//  MomPro
//
//  Created by Andrea Cataldo on 04/02/26.
//

import SwiftUI

enum DeviceType {
    case small       // iPhone SE, 12 Mini, 13 Mini
    case standard    // iPhone 11, 14, 15, 16, 16 17 Pro
    case large       // iPhone Plus, Pro Max
    case ipadMini    // iPad Mini
    case ipadStandard // iPad 11", Air, Pro 11"
    case ipadHuge     // iPad Pro 12.9" / 13" (o futuro 16")

    // Questa costante viene calcolata UNA SOLA VOLTA (Lazy static property)
    static let current: DeviceType = {
        // deprecato
        //let width = UIScreen.main.bounds.width
        
        let width: CGFloat = {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    return windowScene.screen.bounds.width
                }
                // Fallback per sicurezza (se la scena non è ancora pronta)
                return 393 // Larghezza standard iPhone 16/17
            }()
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        
        let detected: DeviceType
        
        if isPad {
            if width <= 744 { detected = .ipadMini }
            else if width <= 834 { detected = .ipadStandard }
            else { detected = .ipadHuge }
        } else {
            if width <= 389 { detected = .small }
            else if width <= 439 { detected = .standard }
            else { detected = .large }
        }
        print("📱 [DeviceType] Rilevato: \(detected) (Larghezza schermo: \(width)pt)")
        return detected
    }()
}
