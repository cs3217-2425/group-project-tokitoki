//
//  MotionPrimitive.swift
//  TokiToki
//
//  Created by wesho on 30/3/25.
//

import UIKit

class MotionPrimitive: VisualFXPrimitive {
    func apply(to view: UIView, with parameters: [String: Any], completion: @escaping () -> Void) {
        guard let motionTypeString = parameters["motionType"] as? String,
              let motionType = MotionParameters.MotionType(rawValue: motionTypeString) else {
            completion()
            return
        }

        // Create a container view for the animation
        let containerView = UIView(frame: view.bounds)
        containerView.backgroundColor = .clear
        view.addSubview(containerView)

        // Get content to animate (could be an image or shape)
        let content = parameters["content"] as? UIView ?? createDefaultContent(with: parameters)
        containerView.addSubview(content)

        // Use the strategy pattern to apply the motion
        let strategy = MotionStrategyRegistry.shared.getStrategy(for: motionType)
        strategy.applyMotion(to: content, in: containerView, with: parameters, completion: completion)
    }

    private func createDefaultContent(with parameters: [String: Any]) -> UIView {
        let size = parameters["contentSize"] as? CGSize ?? CGSize(width: 30, height: 30)
        let color = parameters["color"] as? UIColor ?? .white

        let contentView = UIView(frame: CGRect(origin: .zero, size: size))
        contentView.backgroundColor = color
        contentView.layer.cornerRadius = min(size.width, size.height) / 2

        return contentView
    }
}
