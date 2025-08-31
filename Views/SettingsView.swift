//
//  Settings.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 19/06/2025.
//

import SwiftUI
import SwiftData

struct Settings: View {
    @State var TfLColour = colourRGB(0, 25, 168)
    @EnvironmentObject var routeSettings : routeSettings
    @EnvironmentObject var stationSettings : stationSettings
    var body: some View {
        NavigationView{
            VStack{
                Text("Settings")
                    .font(.system(size: 36, weight: .bold, design: .default))
                List{
                    Section{
                        Text("Station Timetable")
                            .font(.caption)
                        Picker("Sort timetable by", selection: $stationSettings.sortArrivals) {
                            
                            ForEach(stationSettings.sortTypes, id: \.self) {
                                Text($0)
                            }
                        }
                    }
                    Section{
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
                        Toggle("Show TfL routes", isOn: $routeSettings.showTfLRoutes)
                            .toggleStyle(SwitchToggleStyle(tint: TfLColour))
                        Toggle("Show National Rail routes", isOn: $routeSettings.showNRRoutes)
                        Toggle("Show Tram routes", isOn: $routeSettings.showTramRoutes)
                        Toggle("Show transfers", isOn: $routeSettings.showTransfers)
                    }
                    Section{
                        
                        let info = Image(systemName: "info.circle")
                        NavigationLink(destination: AboutView()){
                            Text("\(info)\tInformation")
                        }
                        
                        
                    }
                    
                    
                }
            }
        }
        
        
    }
}
enum arrivalSort {
    case time
    case line
}
#Preview {
    
    Settings()
        .environmentObject(routeSettings())
        .environmentObject(stationSettings())
}
