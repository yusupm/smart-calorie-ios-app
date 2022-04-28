//
//  Extensions.swift
//  Final project
//
//  Created by BOLT on 19/04/2022.
//

import SwiftUI

extension Color {
    static func rgb(r: Double, g: Double, b: Double) -> Color {
        return Color(red: r / 255, green: g / 255, blue: b / 255)
    }
    static let backgroundColor = Color(#colorLiteral(red: 0.974566576, green: 0.974566576, blue: 0.974566576, alpha: 1))
    static let foregroundColor = Color(#colorLiteral(red: 0.3544496118, green: 0.3544496118, blue: 0.3544496118, alpha: 1))
    static let textColor = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
    static let textColor1 = Color(#colorLiteral(red: 0.3544496118, green: 0.3544496118, blue: 0.3544496118, alpha: 1))
//    static let backgroundColor = Color.rgb(r: 21, g: 22, b: 33)
    static let outlineColor = Color.rgb(r: 54, g: 255, b: 203)
    static let trackColor = Color.rgb(r: 45, g: 56, b: 95)
    static let pulsatingColor = Color.rgb(r: 73, g: 113, b: 148)
}
