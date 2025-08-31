//
//  StatusView.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 25/06/2025.
//

import SwiftUI
import SwiftData
struct StatusView: View {
    @ObservedObject var Lines : DatabaseViewModel

    @Environment(\.self) var environment
    
    var body: some View {
        
        let limit : Float = 100/255
        VStack{
            Text("Line Status")
            Button ("Refresh",action: {
                Task{
                    await Lines.getStatus()
                }
            })
            .frame(width: 100, height: 30)
            List(Lines.TrainLines) {line in
                
                
                
                //line.status = getStatus(line: line)
                
                let comp = line.colour.resolve(in: environment)
                Section{
                    VStack(alignment: .leading){
                        Text("\(line.name) Line")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        if !Lines.isLoading  {

                            let info = line.status
                            if "Good service" != info?.descrp {
                                
                                Text("\(info?.statusType ?? "")")
                                    .font(.caption)
                                Text("\(info?.descrp ?? "")")
                                    .font(.caption)
                            } else {
                                Text("Good Service")
                            }
                            
                        } else{
                            HStack{
                                ProgressView("Loading...")
                            }
                            
                            
                        }
                        //Text("\(line.status)")
                    }
                    .foregroundStyle(comp.red < limit && comp.blue < limit && comp.green < limit ? Color.white : Color.black)
                    
                    .listRowBackground(line.colour)
                }
                
            }

            

            
        }
        .task{
            if Lines.TrainLines.isEmpty {
                await Lines.importLines()
            }
            await Lines.getStatus()
            
        }
        
        
        
    }


}


#Preview {
    let viewModel = DatabaseViewModel()
    StatusView(Lines: viewModel)
}
 
