//
//  Reusable Assets.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 09/08/2025.
//

import SwiftUI

func midImage(_ bodyColour : Color, _ bgColour : Color) -> some View {
    Image(systemName: "circle")
            .foregroundStyle(bodyColour)
            .background(bgColour)
            .clipShape(Circle())
            .imageScale(.small)
}

func smallImage(_ bodyColour : Color) -> some View {
    Image(systemName: "circle.fill")
            .foregroundStyle(bodyColour)
            .clipShape(Circle())
            .imageScale(.small)
}
func largeImage(_ bodyColour : Color, _ bgColour : Color) -> some View {
    Image(systemName: "circle.circle")
            .foregroundStyle(bodyColour)
            .background(bgColour)
            .clipShape(Circle())
            .imageScale(.large)
}
func targetIcon() -> some View {
    Image(systemName: "circle")
        .foregroundStyle(.red)
        .background(.white)
        .clipShape(Circle())
        .imageScale(.large)
}

