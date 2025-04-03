//
//  IGachaEvent.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//

import Foundation

// Event interface
protocol IGachaEvent: Identifiable {
    var name: String { get }
    var description: String { get }
    var startDate: Date { get }
    var endDate: Date { get }
    var isActive: Bool { get }
    
    // Returns rate modifiers for specific items
    func getRateModifiers() -> [String: Double]
}
