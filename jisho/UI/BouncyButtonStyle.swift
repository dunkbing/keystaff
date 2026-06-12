//
//  BouncyButton.swift
//  TikimUI
//
//  Created by Bùi Đặng Bình on 15/3/25.
//

import SwiftUI

public struct BouncyButtonStyle: ButtonStyle {
    var duration: Double
    var scale: Double

    public init(duration: Double = 0.2, scale: Double = 0.95) {
        self.duration = duration
        self.scale = scale
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.easeOut(duration: duration), value: configuration.isPressed)
    }
}
