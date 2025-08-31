//
//  Repeatables.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 07/08/2025.
//

import SwiftUI

func clearButton(for text : Binding<String>) -> some View {
    Button("", systemImage: "xmark.circle.fill", action: {
        text.wrappedValue = ""
    })
    .foregroundStyle(Color.gray)
    .opacity(0.5)
}
func searchField(text : Binding<String>) -> some View {
    HStack {
        TextField("Search", text: text)
            .frame(height: 50)
            .cornerRadius(8.0)
        if !text.wrappedValue.isEmpty{
            clearButton(for: text)
        }
        
    }
}

func colourRGB(_ r: Int? , _ g: Int?, _ b: Int?) -> Color { //Returns percise colours
    return Color(red: Double(r ?? 0) / 255, green: Double(g ?? 0) / 255, blue: Double(b ?? 0) / 255)
}
func colourRGB (_ values : [Int]) -> Color {
    guard values.count == 3 else {
        return .black
    }
    return Color(
        red: Double(values[0]) / 255.0,
        green: Double(values[1]) / 255.0,
        blue: Double(values[2]) / 255.0
    )
}
func colourRGB() -> Color { //used as temp colour
    return .black
}


