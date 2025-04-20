//
//  LevelMatrix.swift
//  TokiToki
//
//  Created by proglab on 17/4/25.
//

import Foundation

let maxLevel = 30
let baseExp = 100
let curveFactor = 1.5

let levelInfo: [Int] = (0...maxLevel).map { level in
    if level == maxLevel {
        return 0
    }
    return Int(Double(baseExp) * pow(Double(level), curveFactor))
}
