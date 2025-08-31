//
//  Weather.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 20/08/2025.
//
import SwiftUI

struct weatherIcon : View {
    var icon: String
    var body: some View {
        Image(icon)
            .resizable()
            .frame(width: 32, height: 32)
    }
}
struct scrollingText : View {
    var body: some View {
        Text("Scrolling Text")
            .padding()
            .frame(width: 200, height: 50)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1))
            )
    }
}
enum WeatherType: String, CaseIterable {
    case sunny = "sunny"
    case cloudy = "cloudy"
    case rainy = "rainy"
    case storm
    case snow
    
}
#Preview {
    scrollingText()
}
