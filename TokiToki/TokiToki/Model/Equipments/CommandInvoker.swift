//
//  CommandInvoker.swift
//  TokiToki
//
//  Created by Wh Kang on 31/3/25.
//


import Foundation

class CommandInvoker {
    private var commandHistory: [EquipmentCommand] = []
    
    func execute(command: EquipmentCommand) {
        command.execute()
        commandHistory.append(command)
    }
    
    func undoLast() {
        if let lastCommand = commandHistory.popLast() {
            lastCommand.undo()
        }
    }
}