//
//  GachaItem.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 31/3/25.
//
import Foundation

/// Gacha‐item interface: holds only metadata and defers real object creation.
protocol IGachaItem: Identifiable {
    var name: String { get }
    var rarity: ItemRarity { get }
    var elementType: [ElementType] { get }
    var ownerId: UUID? { get set }
    var dateAcquired: Date? { get set }

    /// Lazily produce the real domain object.
    func createInstance() -> Any
}
