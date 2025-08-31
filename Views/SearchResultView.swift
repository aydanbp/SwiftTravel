//
//  SearchResultView.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 23/08/2025.
//
import SwiftUI
import MapKit

struct SearchResultView: View {
    
    @ObservedObject var viewModel : StationDataViewModel
    @Binding var cameraRegion: MapCameraPosition
    @Binding var updateText : String
    @EnvironmentObject var searchData : stationPassData
    @Binding var showPaths : Bool
    
    var body: some View {
        if !showPaths {
            List(searchData.searchResults){ result in
                HStack{
                    Button(result.stationName){

                        
                        updateText = result.stationName
                        
                    }
                }
                
                
            }
        } else {
            Button("Clear", action: {
                showPaths = false
            })
                List(viewModel.allPaths, id: \.self){ result in
                    let linesPresent : [String] = returnUniqueLines(result).sorted()
                    Button(linesPresent.joined(separator: ", ")){
                        viewModel.shortestPath = result
                        
                    }
                    
                }
            
        }
        
        
    }
    
}

private func returnUniqueLines(_ paths : [Route]) -> Set<String> {
    var linesPresent : Set<String> = []
    for path in paths {
        
        linesPresent.insert(path.line)
    }
    return linesPresent
}
