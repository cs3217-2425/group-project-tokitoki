//
//  ScreenwideVisualFXComponent.swift
//  TokiToki
//
//  Created by wesho on 18/4/25.
//

import UIKit

class ScreenwideVisualFXComponent<E: BattleEvent>: VisualFXComponent<E>, ViewControllerProvider {
    weak var viewController: UIViewController?

    init(viewProvider: @escaping (UUID) -> UIView?, viewController: UIViewController) {
        self.viewController = viewController
        super.init(viewProvider: viewProvider)
    }
}

protocol ViewControllerProvider {
    var viewController: UIViewController? { get }
}
