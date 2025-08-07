//
//  Untitled.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 19/06/2025.
//

import SwiftUI

struct MainTabView : View {
    var body: some View {

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
                
                StatusView()
                    .tabItem {
                        Image(systemName: "dot.radiowaves.left.and.right")
                        Text("Status")
                    }

                
            }
            .background(Color.black)
            


        
    }
}
