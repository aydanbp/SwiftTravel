//
//  SearchView.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 25/06/2025.
//

import SwiftUI

struct SearchView: View {
    var body: some View {
        let _ : String = "Search"
        ZStack{
            TextField("Search", text: .constant(""))
                .padding()
        }
        
    }
}
