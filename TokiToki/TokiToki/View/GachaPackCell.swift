//
//  GachaPackCell.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 15/4/25.
//
import Foundation
import UIKit

class GachaPackCell: UICollectionViewCell {
    private let packNameLabel = UILabel()
    private let packCostLabel = UILabel()
    private let containerView = UIView()
    private let drawButton = UIButton(type: .system)

    weak var delegate: GachaPackCellDelegate?
    private var packName: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        // Container view setup
        containerView.backgroundColor = .systemBlue
        containerView.layer.cornerRadius = 15
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        // Create a stack view to center content vertically
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)

        // Pack name label setup
        packNameLabel.textAlignment = .center
        packNameLabel.font = UIFont.boldSystemFont(ofSize: 35)
        packNameLabel.textColor = .white
        packNameLabel.numberOfLines = 0

        // Draw button setup
        drawButton.setTitle("DRAW", for: .normal)
        drawButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        drawButton.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        drawButton.setTitleColor(.white, for: .normal)
        drawButton.layer.cornerRadius = 12
        drawButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
        drawButton.layer.shadowColor = UIColor.black.cgColor
        drawButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        drawButton.layer.shadowRadius = 4
        drawButton.layer.shadowOpacity = 0.3
        drawButton.addTarget(self, action: #selector(drawButtonTapped), for: .touchUpInside)

        // Pack cost label setup
        packCostLabel.textAlignment = .center
        packCostLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        packCostLabel.textColor = .white
        packCostLabel.numberOfLines = 1

        // Add views to stack view
        stackView.addArrangedSubview(packNameLabel)
        stackView.addArrangedSubview(drawButton)
        stackView.addArrangedSubview(packCostLabel)

        // Add constraints for stack view
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])

        // Add shadow to container
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOpacity = 0.3

        // Add visual selection effect
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        selectedBackgroundView.layer.cornerRadius = 15
        self.selectedBackgroundView = selectedBackgroundView
    }

    @objc private func drawButtonTapped() {
        if let packName = packName {
            delegate?.didTapDraw(forPackName: packName)
        }
    }

    func configure(with pack: GachaPack?) {
        if let pack = pack {
            packNameLabel.text = pack.name.uppercased()
            packCostLabel.text = "🟡 \(pack.cost)"
            packName = pack.name

            // Change background color based on rarity/cost
            if pack.cost >= 300 {
                containerView.backgroundColor = UIColor(red: 0.435, green: 0.31, blue: 0.51, alpha: 1)
            } else if pack.cost >= 200 {
                containerView.backgroundColor = UIColor(red: 0.192, green: 0.427, blue: 0.447, alpha: 1)
            } else if pack.cost >= 100 {
                containerView.backgroundColor = UIColor(red: 0.267, green: 0.518, blue: 0.353, alpha: 1)
            } else {
                containerView.backgroundColor = UIColor(red: 0.878, green: 0.396, blue: 0.176, alpha: 1)
            }

            // Show draw button for available packs
            drawButton.isHidden = false
        } else {
            packNameLabel.text = "No Packs Available"
            packCostLabel.text = "🟡 0"
            containerView.backgroundColor = .systemGray
            drawButton.isHidden = true
        }
    }
}

// Protocol for handling draw button taps
protocol GachaPackCellDelegate: AnyObject {
    func didTapDraw(forPackName packName: String)
}
