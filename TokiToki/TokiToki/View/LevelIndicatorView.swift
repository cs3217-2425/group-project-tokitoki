//
//  LevelIndicatorView.swift
//  TokiToki
//
//  Created by proglab on 18/4/25.
//

import UIKit

class LevelIndicatorView: UIView {
    private let circleView = UIView()
    private let levelLabel = UILabel()

    init(level: Int, element: ElementType, diameter: CGFloat = 40) {
        super.init(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        setupView(level: level, element: element, diameter: diameter)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView(level: Int, element: ElementType, diameter: CGFloat) {
        // Circle setup
        circleView.frame = bounds
        circleView.backgroundColor = elementToColour[element]
        circleView.layer.cornerRadius = diameter / 2
        circleView.layer.masksToBounds = true
        addSubview(circleView)

        // Level label setup
        levelLabel.text = "\(level)"
        levelLabel.textAlignment = .center
        levelLabel.font = UIFont.boldSystemFont(ofSize: diameter / 2)
        levelLabel.textColor = element == .light ? .black : .white // Contrast for white
        levelLabel.frame = bounds
        addSubview(levelLabel)
    }
}
