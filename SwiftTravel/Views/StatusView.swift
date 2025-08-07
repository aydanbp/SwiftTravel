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
    @Environment(\.self) var environment
    
    var body: some View {
        let limit : Float = 100/255
        VStack{
            Text("Line Status")
            
            List(Lines.Lines) {line in
                @State var comp : Color.Resolved = line.colour.resolve(in: environment)
                Section{
                    VStack{
                        Text("\(line.id) Line")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Red: \(comp.red)")
                        Text("Green: \(comp.green)")
                        Text("Blue: \(comp.blue)")
                    }
                    .foregroundStyle(comp.red < limit && comp.blue < limit && comp.green < limit ? Color.white : Color.black)
                    
                    .listRowBackground(colorFor(line: line.id))
                    //.border(Color.black, width: 1)
                }
                

                
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
 
