//
//  Untitled.swift
//  SwiftTravel_v2
//
//  Created by Aydan Buncombe-Paul on 05/09/2025.
//

import SwiftUI

struct TrainArrivalView : View {
    @State private var state : ViewState = .loading
    @StateObject var schedueler = TrainScheduelViewModel()
    private var TfLArrivals : [UnifiedArrivalModel]{
        schedueler.scheduel.filter { $0.source.contains("TFL")}
    }
    private var NRArrivals : [UnifiedArrivalModel]{
        schedueler.scheduel.filter { $0.source.contains("NR")  && !$0.lineName.contains("Elizabeth") }
    }
    let Station : TrainStation
    var body: some View {
        VStack{
            Text(Station.stationName)
                .font(.headline)
            switch state{
            case .loading:
                ProgressView()
                    .padding()
                Text("Loading...")
            case .content:
                switch Station.type {
                case "T":
                    Text("Powered by TfL Open API")
                        .font(.caption)
                        .fontWeight(.light)
                case "N":
                    Text("Powered by National Rail Enquiries")
                        .font(.caption)
                        .fontWeight(.light)
                case "C":
                    Text("Powered by National Rail Enquiries & TfL API")
                        .font(.caption)
                        .fontWeight(.light)
                default:
                    Text("")
                }
            case .noData:
                Text("No Data found...")
            }
            if state == .content{
                List(){
                    if Station.type == "C" ||  Station.type == "T"{
                        Section(String("TfL Arrivals")){
                            ForEach(TfLArrivals){ item in
                                TfLListItem(item: item)
                            }
                        }
                    }
                    if Station.type == "C" ||  Station.type == "N"{
                        Section(String("National Rail Arrivals")){
                            ForEach(NRArrivals){ item in
                                NRListItem(item: item)
                            }
                            
                        }
                        Image("NRE_Powered_logo.jpg")
                            .frame(width: 200, height: 100)
                    }
                    
                }
            }
        }
        .task{
            await schedueler.loadSpecificData(id: Station.id, type: Station.type)
            
            if schedueler.scheduel.isEmpty{
                state = .noData
            } else{
                state = .content
            }
        }
        
    }
        
}
struct TfLListItem : View {
    let item : UnifiedArrivalModel
    var body: some View {
        VStack{
            Text("\(item.lineName) to \(item.destinationName)")
                .font(.headline)
            HStack {
                Text("\(item.platformName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if let timeInSeconds = item.timeToStation {
                    Text("Arriving in \(timeInSeconds / 60) mins")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(timeInSeconds<5 ? .red : .secondary)
                }
                Circle()
                    .foregroundStyle(colorFor(line: item.lineName))
                    .frame(width: 10, height: 10)
            }
        }
        

    }
}
struct NRListItem : View {
    let item : UnifiedArrivalModel
    var body: some View {
        VStack{
            Text("\(item.lineName) to \(item.destinationName)")
                .font(.headline)
            HStack{
                Text("Platform: \(item.platformName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "train.side.rear.car")
                    if let coachCount = item.coachCount {
                        //Text("Formed of \(coachCount) Coaches")
                        switch coachCount {
                        case 1...4:
                            Image(systemName: "train.side.middle.car")
                            
                        case 5...8:
                            Image(systemName: "train.side.middle.car")
                            Image(systemName: "train.side.middle.car")
                            
                            
                        case 9...20:
                            Image(systemName: "train.side.middle.car")
                            Image(systemName: "train.side.middle.car")
                            Image(systemName: "train.side.middle.car")
                        default:
                            Image(systemName: "train.side.middle.car")
                        }
                    }
                    Image(systemName: "train.side.front.car")

                }
            }
            if let schedTime = item.scheduledTime,
               let actTime = item.estimatedTime{
                switch actTime{
                case "Cancelled":
                    Text("Cancelled")
                        .foregroundStyle(.red)
                        .bold()
                case "On Time":
                    Text("Departing at: \(schedTime) - On Time")
                default:
                    Text("Scheduled for: \(schedTime) - Actual: \(actTime)")
                }
                if actTime == "On time" {
                    
                } else{
                   
                }
                
            }
        }
        

        
    }
        
}
enum ViewState{
    case loading
    case content
    case noData
}
