//
//  MainTabView.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 02/09/2025.
//

import SwiftUI

struct MainTabView : View {
    var body: some View {
        TabView {
            MainMap()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
            StatusView()
                .tabItem {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                    Text("Status")
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
    }
}
