//
//  ElementData.swift
//  TokiToki
//
//  Created by wesho on 17/3/25.
//

import Foundation

struct ElementData: Codable {
    let id: String
    let name: String
    let description: String
    let effectiveness: [String: Double]
}

struct ElementsData: Codable {
    let elements: [ElementData]
}
