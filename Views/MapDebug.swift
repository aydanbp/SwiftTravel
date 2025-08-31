//
//  MapDebug.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 09/08/2025.
//
import SwiftUI
import MapKit

struct degubInfo: View {
    @Binding var region : MKCoordinateRegion
    @State var ZoomLevel = 0.75
    var visibleNo : Int
    var totalNo : Int
    @StateObject var viewModel = StationDataViewModel()
    
    var body: some View {
        VStack(){
            
            HStack(){ //Zoom label
                Button("+", action: {
                    region.span.latitudeDelta = region.span.latitudeDelta * ZoomLevel
                    region.span.longitudeDelta = region.span.longitudeDelta * ZoomLevel
                })
                .frame(width: 50, height: 50)
                .font(.title)
                Text("|")
                    .foregroundStyle(.gray)
                    .font(.largeTitle)
                Button("-", action: {
                    region.span.latitudeDelta = region.span.latitudeDelta / ZoomLevel
                    region.span.longitudeDelta = region.span.longitudeDelta / ZoomLevel
                })
                .frame(width: 50, height: 50)
                .font(.title)
                
            }
            .padding(10)
            .background(.thinMaterial)
            .cornerRadius(8)
            .padding(.bottom, 30)
            Text("Visible Stations: \(visibleNo) of \(totalNo)")
                .padding(10)
                .background(.thinMaterial)
                .cornerRadius(8)
                .padding(.bottom, 30)
            Text ("Region:  \(region.span)")
                .padding(10)
                .background(.thinMaterial)
                .cornerRadius(8)
                .padding(.bottom, 30) 
        }
    }
}
