//
//  ButtonStyle.swift
//  MomPro
//
//  Created by Andrea Cataldo on 02/02/26.
//

import SwiftUI

struct SquishyButtonEffect: ButtonStyle {

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        configuration.label
        .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
        .brightness(configuration.isPressed ? -0.0 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.4, blendDuration: 0), value: configuration.isPressed)
    }
}
