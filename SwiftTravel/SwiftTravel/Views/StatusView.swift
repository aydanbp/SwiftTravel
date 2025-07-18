//
//  StatusView.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 25/06/2025.
//

import SwiftUI
import SwiftData
struct StatusView: View {
    @StateObject var Lines = LineData()
    var body: some View {
        VStack{
            Text("Line Status")
            List(Lines.Lines) {line in
                VStack{
                    Text(line.id)
                }
                .background(line.colour)
                
            }
        }
        .task{
            await Lines.loadLine()
        }
        
    }
}
#Preview { 
    StatusView()
}
 
