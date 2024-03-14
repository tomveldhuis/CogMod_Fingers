//
//  FingersViewModel.swift
//  Fingers
//
//  Created by Tom on 28/02/2024.
//

import SwiftUI

class FingersViewModel: ObservableObject {
    private var model: FingersModel
    var runCount: Int
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    init() {
        self.model = FingersModel()
        self.runCount = 3
        //_ = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        //self.runTimer()
    }
    
    
    
//    func runTimer() {
//        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
//            if self.runCount == 0 {
//                print("Finished!")
//                timer.invalidate()
//            } else {
//                print(self.runCount)
//                self.runCount -= 1
//            }
//        }
//    }
}
