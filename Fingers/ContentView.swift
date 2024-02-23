//
//  ContentView.swift
//  Fingers
//
//  Created by Tom on 19/02/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        return ZStack(content: {
            Circle()
                .fill(.red)
                .padding()
            
            Text("Hello,")
                .padding()
        })
//
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
        }
    }
}
