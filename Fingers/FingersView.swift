//
//  ContentView.swift
//  Fingers
//
//  Created by Tom on 19/02/2024.
//

import SwiftUI

struct FingersView: View {
    @ObservedObject var fingersGame: FingersViewModel
    
    var body: some View {
        return ZStack(content: {
            
        })
    }
}

struct FingersView_Previews: PreviewProvider {
    static var previews: some View {
        let model = FingersViewModel()
        FingersView(fingersGame: model)
    }
}
