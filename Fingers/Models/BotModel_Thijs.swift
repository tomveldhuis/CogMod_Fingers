import Foundation

// Struct to use mutating functions
struct BotModel_Thijs : BotModelProtocol {
    /// Player name
    var name: String
    /// Total amount of players in the current game
    var playerCount: Int
    /// Break tendency
    var breakTendency: Double
    /// The trace from the model
    var traceText: String = ""
    /// The model code
    var modelText: String = ""
    /// Part of the contents of DM that can needs to be displayed in the interface
    var dmContent: [PublicChunk] = []
    /// Boolean that states whether the model is waiting for an action.
    var waitingForAction = false
    /// String that is displayed to show the outcome of a round
    var feedback = ""
    /// Time between two rounds
    var breakTime: Double = 5
    /// The ACT-R model
    internal var model = Model()
    
    /// Run the model until done, or until it reaches a +action>
    mutating func run(isActive: Bool) {
        // Update goal chunk
        goalCheck(isActive: isActive)
        
        let goal = model.buffers["goal"]!
        var done = false
        while !done {
            // Switch between states in the goal buffer
            switch (goal.slotvals["state"]!.description) {
                case "deciding_extreme":
                    done = decideExtreme(goal: goal)
                case "deciding_personal":
                    done = decidePersonal(goal: goal)
                case "predicting":
                    addToTrace(string: "Retrieving prediction from memory...")

                    // Use blended retrieval for prediction value
                    let pattern = Chunk(s: "retrieval", m: model)
                    pattern.setSlot(slot: "isa", value: "lastPrediction")
                    pattern.setSlot(slot: "win", value: "yes")
                    let (latency, result) = model.dm.blendedPartialRetrieve(chunk: pattern, mismatchFunction: mismatchFunction)
                    model.time += 0.05 + latency

                    let imaginal = model.buffers["imaginal"]!
                    if let retrievedChunk = result {
                        // Put retrieved prediction in the imaginal buffer
                        imaginal.setSlot(slot: "prediction", value: retrievedChunk.slotvals["result"]!)
                        addToTrace(string: "Found prediction chunk: \(retrievedChunk.slotvals["result"]!.description)")
                    } else {
                        // Retrieval failure: make a random prediction (value between 0 and playerCount)
                        addToTrace(string: "No prediction chunk found")
                        let numPlayers = Int(goal.slotvals["numPlayers"]!.number()!)
                        let randomPrediction = Double(Int.random(in: 0...numPlayers))
                        imaginal.setSlot(slot: "prediction", value: randomPrediction)
                        addToTrace(string: "Random prediction is made instead: \(randomPrediction.description)")
                        model.time += 0.05
                    }

                    // Make an action chunk and wait for the
                    // game to finish the round
                    let action = Chunk(s: "action", m: model)
                    action.setSlot(slot: "isa", value: "decision_prediction")
                    action.setSlot(slot: "decision", value: imaginal.slotvals["decision"]!)
                    action.setSlot(slot: "prediction", value: imaginal.slotvals["prediction"]!)
                    model.buffers["action"] = action
                    model.time += 0.05
                    addToTrace(string: "Created an action chunk")

                    goal.setSlot(slot: "state", value: "waiting")
                    done = true
                    model.waitingForAction = true
                    addToTrace(string: "Waiting for the round to finish...")
                case "waiting":
                    addToTrace(string: "Updating DM with new knowledge...")

                    // Update DM with new knowledge from the current round
                    let action = model.buffers["action"]!
                    let outputOnCup = Int(action.slotvals["result"]!.number()!)

                    // Add result to DM
                    let newResult = Chunk(s: "result", m: model)
                    newResult.setSlot(slot: "isa", value: "lastResult")
                    newResult.setSlot(slot: "result", value: Double(outputOnCup))
                    model.dm.addToDM(newResult)
                    addToTrace(string: "Added current result to DM")
                
                    // Add own decision to DM
                    let decision = model.buffers["imaginal"]!.slotvals["decision"]!.description
                    let newDecision = Chunk(s: "decision", m: model)
                    newDecision.setSlot(slot: "isa", value: "myDecision")
                    if decision == "stay" {
                        newDecision.setSlot(slot: "decision", value: 1.0)
                    } else if decision == "pull" {
                        newDecision.setSlot(slot: "decision", value: 0.0)
                    }
                    model.dm.addToDM(newDecision)
                    addToTrace(string: "Added current decision to DM")

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
                    addToTrace(string: "Added current prediction to DM")

                    // Add imaginal buffer to DM
                    let imaginal = model.buffers["imaginal"]!
                    model.dm.addToDM(imaginal)

                    // Return to the "deciding" state and wait for the next round
                    goal.setSlot(slot: "state", value: "deciding")
                    done = true
                    addToTrace(string: "Waiting for the next round...")
                    model.waitingForAction = true
                    model.time += breakTime
                default:
                    done = true
            }
            update()
        }
    }
    
    //----------------------------
    //--------- Routines ---------
    //----------------------------
    
    func goalCheck(isActive: Bool) {
        if model.buffers["goal"] == nil {
            // Set initial goal buffer
            let chunk = Chunk(s: model.generateName(string: "goal"), m: model)
            chunk.setSlot(slot: "isa", value: "goal")
            chunk.setSlot(slot: "state", value: "deciding_extreme")
            chunk.setSlot(slot: "numPlayers", value: Double(playerCount))
            chunk.setSlot(slot: "breakTendency", value: breakTendency)
            if isActive {
                chunk.setSlot(slot: "isActive", value: "yes")
            } else {
                chunk.setSlot(slot: "isActive", value: "no")
            }
            model.buffers["goal"] = chunk
        } else {
            // Ensure that the goal buffer contains
            // information about the current player
            let goal = model.buffers["goal"]!
            if isActive {
                goal.setSlot(slot: "isActive", value: "yes")
            } else {
                goal.setSlot(slot: "isActive", value: "no")
            }
        }
    }
    
    func decideExtreme(goal: Chunk) -> Bool {
        // Create a new chunk for the imaginal buffer
        let imaginal = Chunk(s: model.generateName(string: "imaginal"), m: model)
        model.time += model.imaginalActionTime
        model.buffers["imaginal"] = imaginal
        addToTrace(string: "Created new imaginal chunk")
    
        // Retrieval of results: regular
        addToTrace(string: "Retrieving result chunks from memory...")

        let retrieval = Chunk(s: "retrieval", m: model)
        retrieval.setSlot(slot: "isa", value: "lastResult")
        let (latency, result) = model.dm.retrieve(chunk: retrieval)
        model.time += 0.05 + latency
    
        if let retrievedChunk = result {
            // Check if extreme is in retrieved chunk
            let lastResult = Int(retrievedChunk.slotvals["result"]!.number()!)
            addToTrace(string: "Found result chunk: \(lastResult)")
            
            if lastResult == 0 || lastResult == Int(goal.slotvals["numPlayers"]!.number()!) {
                addToTrace(string: "Result chunk contains extreme")
                
                // There is an extreme: check break tendency
                if breakTendencyCheck(breakTendency: goal.slotvals["breakTendency"]!.number()!) {
                    // Break extreme
                    if lastResult == 0 {
                        // Low extreme: stay
                        addToTrace(string: "Break low extreme by deciding: stay")
                        imaginal.setSlot(slot: "decision", value: "stay")
                    } else {
                        // High extreme: pull
                        addToTrace(string: "Break high extreme by deciding: pull")
                        imaginal.setSlot(slot: "decision", value: "pull")
                    }
                } else {
                    // Don't break: random choice
                    randomDecision(imaginal: imaginal)
                    addToTrace(string: "Don't break extreme, make random decision: \(imaginal.slotvals["decision"]!.description)")
                }
                model.time += 0.05
                
                // Go to next state
                return checkNextState(goal: goal, imaginal: imaginal)
            } else {
                // There is no extreme: check for personal pattern
                addToTrace(string: "Found no extreme in result chunk: check personal patterns instead")
                goal.setSlot(slot: "state", value: "deciding_personal")
            }
        } else {
            // Retrieval failure: random choice
            randomDecision(imaginal: imaginal)
            addToTrace(string: "No result chunk found, make random decision: \(imaginal.slotvals["decision"]!.description)")
            
            // Go to next state
            return checkNextState(goal: goal, imaginal: imaginal)
        }
        return false
    }
    
    func decidePersonal(goal: Chunk) -> Bool {
        let imaginal = model.buffers["imaginal"]!
    
        // Retrieval of own decisions: blended
        addToTrace(string: "Retrieving own decision chunks from memory...")
    
        let retrieval = Chunk(s: "retrieval", m: model)
        retrieval.setSlot(slot: "isa", value: "myDecision")
        let (latency, result) = model.dm.blendedRetrieve(chunk: retrieval)
        model.time += 0.05 + latency
    
        if let retrievedChunk = result {
            // Check if personal pattern is in retrieved chunk
            let decision = Double(retrievedChunk.slotvals["decision"]!.number()!)
            addToTrace(string: "Found own decision chunk: \(decision)")
            
            if decision < 0.25 || decision > 0.75 {
                addToTrace(string: "Own decision chunk contains personal pattern")
                
                // There is a personal pattern: check break tendency
                if breakTendencyCheck(breakTendency: goal.slotvals["breakTendency"]!.number()!) {
                    // Break personal pattern
                    if decision < 0.25 {
                        // Pattern is "pull": instead "stay"
                        addToTrace(string: "Break pull pattern by deciding: stay")
                        imaginal.setSlot(slot: "decision", value: "stay")
                    } else {
                        // Pattern is "stay": instead "pull"
                        addToTrace(string: "Break stay pattern by deciding: pull")
                        imaginal.setSlot(slot: "decision", value: "pull")
                    }
                } else {
                    // Don't break: random choice
                    randomDecision(imaginal: imaginal)
                    addToTrace(string: "Don't break personal pattern, make random decision: \(imaginal.slotvals["decision"]!.description)")
                }
                model.time += 0.05
            } else {
                // There is no personal pattern: random choice
                randomDecision(imaginal: imaginal)
                addToTrace(string: "Found no personal pattern in own decision chunk, make random decision: \(imaginal.slotvals["decision"]!.description)")
            }
        } else {
            // Retrieval failure: random choice
            randomDecision(imaginal: imaginal)
            addToTrace(string: "Found no own decision chunk, make random decision instead: \(imaginal.slotvals["decision"]!.description)")
        }
        
        // Go to next state
        return checkNextState(goal: goal, imaginal: imaginal)
    }
    
    func breakTendencyCheck(breakTendency: Double) -> Bool {
        if breakTendency > Double.random(in: 0 ..< 1.0) {
            return true
        }
        return false
    }
    
    func randomDecision(imaginal: Chunk) {
        if actrNoise(noise: 1.0) > 0 {
            imaginal.setSlot(slot: "decision", value: "stay")
        } else {
            imaginal.setSlot(slot: "decision", value: "pull")
        }
        model.time += 0.05
    }
    
    func checkNextState(goal: Chunk, imaginal: Chunk) -> Bool {
        // Go to next state: check if the BotModel is the current player
        if goal.slotvals["isActive"]!.description == "yes" {
            // If yes, then retrieve a prediction value
            goal.setSlot(slot: "state", value: "predicting")
            return false
        } else {
            // If no, then make an action chunk
            // and wait for the game to finish the round
            let action = Chunk(s: "action", m: model)
            action.setSlot(slot: "isa", value: "decision")
            action.setSlot(slot: "decision", value: imaginal.slotvals["decision"]!)
            model.buffers["action"] = action
            model.time += 0.05
            addToTrace(string: "Created an action chunk")

            goal.setSlot(slot: "state", value: "waiting")
            model.waitingForAction = true
            addToTrace(string: "Waiting for the round to finish...")
            return true
        }
    }
    
    //----------------------------
    //-------- Functions ---------
    //----------------------------
    
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

    func addToTrace(string: String) {
        model.addToTrace(string: name + "  " + string)
    }
}
