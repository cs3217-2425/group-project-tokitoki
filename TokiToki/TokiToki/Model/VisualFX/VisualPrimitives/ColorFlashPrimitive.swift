//
//  ColorFlashPrimitive.swift
//  TokiToki
//
//  Created by wesho on 30/3/25.
//

import UIKit

class ColorFlashPrimitive: VisualFXPrimitive {
    func apply(to view: UIView, with parameters: [String: Any], completion: @escaping () -> Void) {
        guard let color = parameters["color"] as? UIColor,
              let intensity = parameters["intensity"] as? CGFloat,
              let fade = parameters["fade"] as? Bool else {
            completion()
            return
        }

        let flashView = UIView(frame: view.bounds)
        flashView.backgroundColor = color.withAlphaComponent(intensity)
        view.addSubview(flashView)

        if fade {
            UIView.animate(withDuration: 0.3, animations: {
                flashView.alpha = 0
            }, completion: { _ in
                flashView.removeFromSuperview()
                completion()
            })
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                flashView.removeFromSuperview()
                completion()
            }
        }
    }
}
