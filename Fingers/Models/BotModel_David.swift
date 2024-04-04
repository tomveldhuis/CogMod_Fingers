import Foundation

// Struct to use mutating functions
struct BotModel_David : BotModelProtocol {
    /// Player name
    var name: String
    /// Total amount of players in the current game
    var playerCount: Int
    /// The trace from the model
    var traceText: String = ""
    /// Time between two rounds
    var breakTime: Double = 5
    /// The model code
    var modelText: String = ""
    /// Part of the contents of DM that can needs to be displayed in the interface
    var dmContent: [PublicChunk] = []
    /// Boolean that states whether the model is waiting for an action.
    var waitingForAction = false
    /// String that is displayed to show the outcome of a round
    var feedback = ""
    /// The ACT-R model
    internal var model = Model()
    
    /// Run the model until done, or until it reaches a +action>
    mutating func run(isActive: Bool) {
        // Init goal buffer
        if model.buffers["goal"] == nil {
            let chunk = Chunk(s: model.generateName(string: "goal"), m: model)
            chunk.setSlot(slot: "isa", value: "goal")
            chunk.setSlot(slot: "state", value: "start")
            chunk.setSlot(slot: "numPlayers", value: Double(playerCount))
            if isActive {
                chunk.setSlot(slot: "isActive", value: "yes")
            } else {
                chunk.setSlot(slot: "isActive", value: "no")
            }
            model.buffers["goal"] = chunk
        } else {
            // Goal buffer should contain most recent information about round
            let goal = model.buffers["goal"]!
            if isActive {
                goal.setSlot(slot: "isActive", value: "yes")
            } else {
                goal.setSlot(slot: "isActive", value: "no")
            }
        }
        let goal = model.buffers["goal"]!
        var done = false
        while !done {
            // Switch between states in the goal buffer
            switch (goal.slotvals["state"]!.description) {
            case "start":
                // Initalize imaginal and set a random decision
                let imaginal = Chunk(s: model.generateName(string: "imaginal"), m: model)
                if actrNoise(noise: 1.0) > 0 {
                    imaginal.setSlot(slot: "decision", value: "stay")
                    model.addToTrace(string: "Start with random decision: stay")
                } else {
                    imaginal.setSlot(slot: "decision", value: "pull")
                    model.addToTrace(string: "Start with random decision: pull")
                }
                model.buffers["imaginal"] = imaginal
                model.time += model.imaginalActionTime
                
                // If active player, retrieve predictions else skip and retrieve decisions instead
                //if goal.slotvals["isActive"]!.description == "yes" {
                //    goal.setSlot(slot: "state", value: "retrieving-prediction")
                //} else {
                //    goal.setSlot(slot: "state", value: "retrieving-decision")
                //}
                
                goal.setSlot(slot: "state", value: "retrieving-decision")
            case "retrieving-decision":
                model.addToTrace(string: "Retrieving decision from memory...")
                let imaginal = model.buffers["imaginal"]!
                let retrieval = Chunk(s: "retrieval", m: model)
                retrieval.setSlot(slot: "isa", value: "lastDecision")
                let (latency, result) = model.dm.retrieve(chunk: retrieval)
                model.time += 0.05 + latency
                if let retrievedChunk = result {
                    // Succesfull retrieval
                    imaginal.setSlot(slot: "decision", value: retrievedChunk.slotvals["decision"]!)
                    model.addToTrace(string: "Retrieved \(retrievedChunk), decision: \(retrievedChunk.slotvals["decision"]!)")
                } else {
                    // Failed retrieval
                    model.addToTrace(string: "No decision chunk found, using random decision instead")
                }
                
                goal.setSlot(slot: "state", value: "deciding")
            case "retrieving-prediction":
                model.addToTrace(string: "Retrieving prediction from memory...")

                // Use blended retrieval for prediction value
                let pattern = Chunk(s: "retrieval", m: model)
                pattern.setSlot(slot: "isa", value: "lastPrediction")
                pattern.setSlot(slot: "win", value: "yes")
                let (latency, result) = model.dm.blendedPartialRetrieve(chunk: pattern, mismatchFunction: mismatchFunction)
                model.time += 0.05 + latency
                
                let imaginal = model.buffers["imaginal"]!
                //let retrieval = Chunk(s: "retrieval", m: model)
                //retrieval.setSlot(slot: "isa", value: "lastPrediction")
                //retrieval.setSlot(slot: "win", value: "yes")
                //let (latency, result) = model.dm.retrieve(chunk: retrieval)
                //model.time += 0.05 + latency
                if let retrievedChunk = result {
                    // Succesfull retrieval
                    imaginal.setSlot(slot: "prediction", value: retrievedChunk.slotvals["prediction"]!)
                    model.addToTrace(string: "Retrieved \(retrievedChunk), prediction: \(retrievedChunk.slotvals["prediction"]!)")
                } else {
                    // Failed retrieval
                    model.addToTrace(string: "No prediction chunk found")
                    let numPlayers = Int(goal.slotvals["numPlayers"]!.number()!)
                    let randomPrediction = Double(Int.random(in: 0...numPlayers))
                    imaginal.setSlot(slot: "prediction", value: randomPrediction)
                    model.addToTrace(string: "Random prediction is made instead: \(randomPrediction.description)")
                    model.time += 0.05
                }
                    
                goal.setSlot(slot: "state", value: "predicting")
            case "deciding":
                model.addToTrace(string: "Retrieving decision from memory...")
            
                // Use regular retrieval for decision ("stay" or "pull")
                let retrieval = Chunk(s: "retrieval", m: model)
                retrieval.setSlot(slot: "isa", value: "lastDecision")
                let (latency, result) = model.dm.retrieve(chunk: retrieval)
                model.time += 0.05 + latency
            
                let imaginal = model.buffers["imaginal"]!
                if let retrievedChunk = result {
                    // Put retrieved decision in the imaginal buffer
                    imaginal.setSlot(slot: "decision", value: retrievedChunk.slotvals["decision"]!)
                    model.addToTrace(string: "Found decision chunk: \(retrievedChunk.slotvals["decision"]!)")
                } else {
                    // Retrieval failure: make a random decision ("stay" or "pull")
                    model.addToTrace(string: "No decision chunk found")
                    if actrNoise(noise: 1.0) > 0 {
                        imaginal.setSlot(slot: "decision", value: "stay")
                        model.addToTrace(string: "Random decision is made instead: stay")
                    } else {
                        imaginal.setSlot(slot: "decision", value: "pull")
                        model.addToTrace(string: "Random decision is made instead: pull")
                    }
                    model.time += 0.05
                }
                
                // Check if the BotModel is the current player
                if goal.slotvals["isActive"]!.description == "yes" {
                    // If yes, then retrieve a prediction value
                    goal.setSlot(slot: "state", value: "retrieving-prediction")
                } else {
                    // If no, then make an action chunk
                    // and wait for the game to finish the round
                    let action = Chunk(s: "action", m: model)
                    action.setSlot(slot: "isa", value: "decision")
                    action.setSlot(slot: "decision", value: imaginal.slotvals["decision"]!)
                    model.buffers["action"] = action
                    model.time += 0.05
                    model.addToTrace(string: "Created an action chunk")
                    
                    goal.setSlot(slot: "state", value: "waiting")
                    done = true
                    model.waitingForAction = true
                    model.addToTrace(string: "Waiting for the round to finish...")
                }
            case "predicting":
                // Make an action chunk and wait for the
                // game to finish the round
                let imaginal = model.buffers["imaginal"]!
                let action = Chunk(s: "action", m: model)
                action.setSlot(slot: "isa", value: "decision_prediction")
                action.setSlot(slot: "decision", value: imaginal.slotvals["decision"]!)
                action.setSlot(slot: "prediction", value: imaginal.slotvals["prediction"]!)
                model.buffers["action"] = action
                model.time += 0.05
                model.addToTrace(string: "Created an action chunk")
            
                goal.setSlot(slot: "state", value: "waiting")
                done = true
                model.waitingForAction = true
                model.addToTrace(string: "Waiting for the round to finish...")
            //case "update-decisions":
            //    model.time += 0.05
            //    goal.setSlot(slot: "state", value: "update-predictions")
            //case "update-predictions":
            //    model.time += 0.05
            //    goal.setSlot(slot: "state", value: "update-decisions")
            case "waiting":
                model.addToTrace(string: "Updating DM with new knowledge...")
            
                // Update DM with new knowledge from the current round
                let action = model.buffers["action"]!
                
                // Add decisions to DM
                let outputOnCup = Int(action.slotvals["result"]!.number()!)
                let numPlayers = Int(goal.slotvals["numPlayers"]!.number()!)

                let newDecision = Chunk(s: "lastDecision", m: model)
                newDecision.setSlot(slot: "isa", value: "lastDecision")
                if numPlayers <= outputOnCup {
                    newDecision.setSlot(slot: "decision", value: "stay")
                } else {
                    newDecision.setSlot(slot: "decision", value: "pull")
                }
                model.dm.addToDM(newDecision)
                
                model.addToTrace(string: "Added current decisions to DM")
            
                // Add current prediction to DM
                let currentPrediction = Int(action.slotvals["currentPrediction"]!.number()!)
                let newPrediction = Chunk(s: "lastPrediction", m: model)
                newPrediction.setSlot(slot: "isa", value: "lastPrediction")
                newPrediction.setSlot(slot: "prediction", value: Double(currentPrediction))
                newPrediction.setSlot(slot: "result", value: Double(outputOnCup))
                if currentPrediction == outputOnCup {
                    newPrediction.setSlot(slot: "win", value: "yes")
                } else {
                    newPrediction.setSlot(slot: "win", value: "no")
                }
                model.dm.addToDM(newPrediction)
                model.addToTrace(string: "Added current prediction to DM")
            
                // Add imaginal buffer to DM
                let imaginal = model.buffers["imaginal"]!
                model.dm.addToDM(imaginal)
                
                // Return to the "deciding" state and wait for the next round
                goal.setSlot(slot: "state", value: "deciding")
                done = true
                model.addToTrace(string: "Waiting for the next round...")
                model.waitingForAction = true
                model.time += breakTime
            default:
                done = true
            }
            update()
        }
    }
    
    /// Modify a slot in the action buffer
    /// - Parameters:
    ///   - slot: the slot to be modified
    ///   - value: the new value
    /// - Returns: whether successful
    func modifyLastAction(slot: String, value: String) -> Bool {
        if model.waitingForAction {
            model.modifyLastAction(slot: slot, value: value)
            return true
        } else {
            return false
        }
    }
    
    func updateActionChunk(outputOnCup: Int, currentPrediction: Int) {
        model.modifyLastAction(slot: "result", value: Double(outputOnCup))
        model.modifyLastAction(slot: "currentPrediction", value: Double(currentPrediction))
    }
    
    func mismatchFunction(x: Value, y: Value) -> Double? {
        var mismatch: Double? = nil
        // No mismatch penalty if slotvalue of "win" is equal to "yes" for both values
        if x.isEqual(value: Value.Text("yes")) && y.isEqual(value: Value.Text("yes")) {
            mismatch = 0.0
        }
        // If not, mismatch penalty is -1.0
        if x.isEqual(value: Value.Text("yes")) && y.isEqual(value: Value.Text("no")) {
            mismatch = -1.0
        }
        if x.isEqual(value: Value.Text("no")) && y.isEqual(value: Value.Text("yes")) {
            mismatch = -1.0
        }
        if x.isEqual(value: Value.Text("no")) && y.isEqual(value: Value.Text("no")) {
            mismatch = -1.0
        }
        return mismatch
    }
}
