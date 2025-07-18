//
//  Untitled.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 19/06/2025.
//

import SwiftUI

struct MainTabView : View {
    var body: some View {
        HStack{
            TabView {
                MapView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("Travel Map")
                    }
                
                Settings()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                StatusView()
                    .tabItem {
                        Image(systemName: "dot.radiowaves.left.and.right")
                        Text("Status")
                    }
                
            }
            .background(Color.black)
            
        }
        .padding(20)

        
    }
}
