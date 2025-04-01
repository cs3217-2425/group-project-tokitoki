//
//  GachaItem.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//
import Foundation

protocol IGachaItem: Identifiable {
    var id: UUID { get }
    var name: String { get }
    var rarity: ItemRarity { get }
    var elementType: ElementType { get }
    
    // Optional owner properties
    var ownerId: UUID? { get set }
    var dateAcquired: Date? { get set }
}
