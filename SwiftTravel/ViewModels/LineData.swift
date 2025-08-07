//
//  LineData.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 09/07/2025.
//

import Foundation


class LineData : ObservableObject {
    @Published var Lines : [TrainLine] = []
    func loadLine() async{
        guard let url = Bundle.main.url(forResource: "TFLColours", withExtension: "JSON") else {
            fatalError("LineData not found.")
        }
        do{
            let data = try Data(contentsOf: url)
            let allLines = try JSONDecoder().decode([TrainLine].self, from: data)
            
            self.Lines = allLines
        }
        catch{
            print("Line Decoding Error")
        }
    }
}
