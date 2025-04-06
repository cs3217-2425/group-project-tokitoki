//
//  CollectionViewController.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 6/4/25.
//

import UIKit

class CollectionViewController: HorizontalPeekingPagesCollectionViewController {
    
    var packs: [GachaPack] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    weak var delegate: GachaViewControllerDelegate?

    override func calculateSectionInset() -> CGFloat {
        return 40
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for cell reuse
        collectionView.register(GachaPackCell.self, forCellWithReuseIdentifier: "cell")
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return packs.count > 0 ? packs.count : 1 // At least one cell to show
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GachaPackCell
        
        if packs.count > 0 && indexPath.item < packs.count {
            let pack = packs[indexPath.item]
            cell.configure(with: pack)
        } else {
            // Default empty state
            cell.configure(with: nil)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if packs.count > 0 && indexPath.item < packs.count {
            let selectedPack = packs[indexPath.item]
            delegate?.didSelectPack(pack: selectedPack)
        }
    }
}

// MARK: - GachaPackCell
class GachaPackCell: UICollectionViewCell {
    private let packNameLabel = UILabel()
    private let packCostLabel = UILabel()
    private let containerView = UIView()
    
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
        
        // Pack name label setup
        packNameLabel.textAlignment = .center
        packNameLabel.font = UIFont.boldSystemFont(ofSize: 22)
        packNameLabel.textColor = .white
        packNameLabel.numberOfLines = 0
        packNameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(packNameLabel)
        
        // Pack cost label setup
        packCostLabel.textAlignment = .center
        packCostLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        packCostLabel.textColor = .white
        packCostLabel.numberOfLines = 1
        packCostLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(packCostLabel)
        
        NSLayoutConstraint.activate([
            packNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            packNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            packNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            packCostLabel.topAnchor.constraint(equalTo: packNameLabel.bottomAnchor, constant: 12),
            packCostLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            packCostLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            packCostLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -20)
        ])
        
        // Add shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        containerView.layer.shadowRadius = 5
        containerView.layer.shadowOpacity = 0.3
    }
    
    func configure(with pack: GachaPack?) {
        if let pack = pack {
            packNameLabel.text = pack.name
            packCostLabel.text = "Cost \(pack.cost)"
            
            // Use different colors based on pack cost
            if pack.cost >= 300 {
                containerView.backgroundColor = .systemPurple
            } else if pack.cost >= 200 {
                containerView.backgroundColor = .systemBlue
            } else {
                containerView.backgroundColor = .systemGreen
            }
        } else {
            packNameLabel.text = "No Packs Available"
            packCostLabel.text = "0"
            containerView.backgroundColor = .systemGray
        }
    }
}
