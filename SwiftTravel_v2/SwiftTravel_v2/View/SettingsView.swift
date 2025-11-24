//
//  Settings.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 02/09/2025.
//

import SwiftUI
import _CoreLocationUI_SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    @EnvironmentObject var databaseManager: DatabaseManager
    @EnvironmentObject var routeSettings: routeSettings
    @EnvironmentObject var stationSettings: stationSettings
    public var body: some View {
        NavigationView {
            VStack{
                Text("Settings")
                    .font(.system(size: 36, weight: .bold, design: .default))
                List {
//                    Section("Sort timetable"){
//                        Picker("Sort by", selection: $stationSettings.sortArrivals){
//                            ForEach(stationSettings.sortTypes, id: \.self){
//                                Text($0)
//                            }
//                        }
//                    }
                    Section("Display stations"){
                        Picker("Show \(stationSettings.nodesDisplayed) stations", selection: $stationSettings.nodesDisplayed){
                            ForEach(stationSettings.showStations, id: \.self) {
                                Text($0)
                            }
                        }
                        .onChange(of: stationSettings.nodesDisplayed) {
                            switch stationSettings.nodesDisplayed {
                            case "TfL":
                                stationSettings.showNodes = .tfl
                            case "National Rail":
                                stationSettings.showNodes = .nationalRail
                            case "None":
                                stationSettings.showNodes = .none
                            default:
                                stationSettings.showNodes = .all
                            }
                        }
                    }
                    Section{
                        
                        let info = Image(systemName: "info.circle")
                        NavigationLink(destination: AboutView()){
                            Text("\(info)\tInformation")
                        }
                        
                        
                    }
                    Section("Database management"){
                        Button("Flush Data"){
                            Task {
                                databaseManager.binAllData()
                                await databaseManager.loadAllData()
                            }
                        }
                        
                        Button("Delete Data"){
                            databaseManager.binAllData()
                        }
                    }
                    NavigationLink(destination: NotificationSettingsView()){
                        Text("Notification settings")
                    }
                }
            }
        }
    }
}

