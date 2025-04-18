//
//  BattleLogObserver.swift
//  TokiToki
//
//  Created by proglab on 19/3/25.
//

protocol BattleLogObserver: AnyObject {
    func update(logEntries: [LogEntry])
}
