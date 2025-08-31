//
//  AboutView.swift
//  SwiftTravel
//
//  Created by Aydan Buncombe-Paul on 20/08/2025.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        Text("About SwiftTravel")
            .navigationTitle("About")
        Text("""
             This app is powered by National Rail Enquiries API.
             For more information please visit this link /(link)
             This app is powered by TfL's open API.
             For more information please visit this link /(link)
             """)
    }
}
