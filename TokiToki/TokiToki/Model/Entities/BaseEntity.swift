//
//  BaseEntity.swift
//  TokiToki
//
//  Created by proglab on 18/3/25.
//

import Foundation

class BaseEntity: Entity {
    let id = UUID()
    var components: [String: Component] = [:]

    func addComponent(_ component: Component) {
        let componentName = String(describing: type(of: component))
        components[componentName] = component
    }

    func getComponent<T: Component>(ofType type: T.Type) -> T? {
        let componentName = String(describing: type)
        return components[componentName] as? T
    }

    func removeComponent<T: Component>(ofType type: T.Type) {
        let componentName = String(describing: type)
        components.removeValue(forKey: componentName)
    }
}
