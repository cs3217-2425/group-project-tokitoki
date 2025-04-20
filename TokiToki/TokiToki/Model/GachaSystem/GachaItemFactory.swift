//
//  GachaItemFactory.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/4/25.
//
import Foundation

class GachaItemFactory {

    static func createTokiGachaItem(
        template: TokiData,
        factory: TokiFactoryProtocol
    ) -> TokiGachaItem {
        TokiGachaItem(template: template, tokiFactory: factory)
    }

    static func createEquipmentGachaItem(
        template: EquipmentData,
        factory: EquipmentRepositoryProtocol
    ) -> EquipmentGachaItem {
        EquipmentGachaItem(template: template, equipmentRepository: factory)
    }
}
