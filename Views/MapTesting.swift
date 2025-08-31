//
//  MapTesting.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 24/08/2025.
//

import Swift
import MapKit
import SwiftUI

struct MapTesting : View {
    var body: some View {
        ZStack{
            Map()
            JourneyView()
        }
        
    }
    
}
#Preview {
    MapTesting()
}
