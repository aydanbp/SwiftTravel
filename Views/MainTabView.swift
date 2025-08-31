//
//  Untitled.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 19/06/2025.
//

import SwiftUI

struct MainTabView : View {
    var body: some View {
        let preView = StationDataViewModel()
        let datab = DatabaseViewModel()
        
            TabView {
                MapView2()
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("Second Map")
                    }

                Settings()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                
                StatusView(Lines: datab)
                    .tabItem {
                        Image(systemName: "dot.radiowaves.left.and.right")
                        Text("Status")
                    }
                MapTesting()
                    .tabItem {
                        Image(systemName: "location")
                        Text("Map Testing")
                    }

                
            }
            .background(Color.black)
            


        
    }
}
