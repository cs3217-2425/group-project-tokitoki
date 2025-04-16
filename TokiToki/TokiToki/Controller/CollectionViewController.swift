//
//  CollectionViewController.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 6/4/25.
//

import UIKit


class CollectionViewController: HorizontalScrollViewController {

    var packs: [GachaPack] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }

    weak var delegate: GachaViewControllerDelegate?

    override func calculateSectionInset() -> CGFloat {
        // Adjust the inset to make cards more centered
        let collectionViewWidth = collectionView.bounds.width
        let itemWidth = collectionViewFlowLayout.itemSize.width
        return (collectionViewWidth - itemWidth) / 2
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Register for cell reuse
        collectionView.register(GachaPackCell.self, forCellWithReuseIdentifier: "cell")
        
        // Add a bit of spacing between cells
        collectionViewFlowLayout.minimumLineSpacing = 50
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        !packs.isEmpty ? packs.count : 1 // At least one cell to show
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? GachaPackCell else {
            return UICollectionViewCell()
        }

        if !packs.isEmpty && indexPath.item < packs.count {
            let pack = packs[indexPath.item]
            cell.configure(with: pack)
            cell.delegate = self
        } else {
            // Default empty state
            cell.configure(with: nil)
        }

        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !packs.isEmpty && indexPath.item < packs.count {
            let selectedPack = packs[indexPath.item]
            delegate?.didSelectPack(pack: selectedPack)
            
            // Add a subtle animation on selection
            if let cell = collectionView.cellForItem(at: indexPath) {
                UIView.animate(withDuration: 0.1, animations: {
                    cell.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                }, completion: { _ in
                    UIView.animate(withDuration: 0.1) {
                        cell.transform = .identity
                    }
                })
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Recalculate layout when orientation changes
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.collectionViewFlowLayout.invalidateLayout()
            self?.configureCollectionViewLayoutItemSize()
            
            // Keep the current pack centered
            let indexPath = IndexPath(item: self?.indexOfMajorCell() ?? 0, section: 0)
            self?.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        })
    }
}

// MARK: - GachaPackCellDelegate
extension CollectionViewController: GachaPackCellDelegate {
    func didTapDraw(forPackName packName: String) {
        // Find the pack that matches this name
        if let selectedPack = packs.first(where: { $0.name == packName }) {
            delegate?.didSelectPack(pack: selectedPack)
            
            // Also trigger draw action in parent view controller
            if let gachaVC = self.parent as? GachaViewController {
                gachaVC.performDraw(for: selectedPack)
            }
        }
    }
}

// MARK: - GachaPackCell
//class GachaPackCell: UICollectionViewCell {
//    private let packNameLabel = UILabel()
//    private let packCostLabel = UILabel()
//    private let containerView = UIView()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        setupViews()
//    }
//    
//    required init?(coder: NSCoder) {
//        super.init(coder: coder)
//        setupViews()
//    }
//    
//    private func setupViews() {
//        // Container view setup
//        containerView.backgroundColor = .systemBlue
//        containerView.layer.cornerRadius = 15
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(containerView)
//        
//        NSLayoutConstraint.activate([
//            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
//            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
//            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
//        ])
//        
//        // Pack name label setup
//        packNameLabel.textAlignment = .center
//        packNameLabel.font = UIFont.boldSystemFont(ofSize: 22)
//        packNameLabel.textColor = .white
//        packNameLabel.numberOfLines = 0
//        packNameLabel.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(packNameLabel)
//        
//        // Pack cost label setup
//        packCostLabel.textAlignment = .center
//        packCostLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
//        packCostLabel.textColor = .white
//        packCostLabel.numberOfLines = 1
//        packCostLabel.translatesAutoresizingMaskIntoConstraints = false
//        containerView.addSubview(packCostLabel)
//        
//        NSLayoutConstraint.activate([
//            packNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
//            packNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            packNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            
//            packCostLabel.topAnchor.constraint(equalTo: packNameLabel.bottomAnchor, constant: 12),
//            packCostLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
//            packCostLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
//            packCostLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -20)
//        ])
//        
//        // Add shadow
//        containerView.layer.shadowColor = UIColor.black.cgColor
//        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
//        containerView.layer.shadowRadius = 5
//        containerView.layer.shadowOpacity = 0.3
//    }
//    
//    func configure(with pack: GachaPack?) {
//        if let pack = pack {
//            packNameLabel.text = pack.name
//            packCostLabel.text = "Cost \(pack.cost)"
//            
//            // Change background color based on cost
//            if pack.cost >= 300 {
//                containerView.backgroundColor = .systemPurple
//            } else if pack.cost >= 200 {
//                containerView.backgroundColor = .systemBlue
//            } else {
//                containerView.backgroundColor = .systemGreen
//            }
//        } else {
//            packNameLabel.text = "No Packs Available"
//            packCostLabel.text = "0"
//            containerView.backgroundColor = .systemGray
//        }
//    }
//}
