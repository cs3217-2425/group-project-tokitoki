//
//  GachaViewController.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//

import UIKit

class GachaViewController: UIViewController {
    @IBOutlet private var gachaDrawButton: UIButton!
    @IBOutlet private var gachaPackLabel: UILabel!
    @IBOutlet private var packSelectorLabel: UILabel!
    @IBOutlet private var gachaPackCollectionView: UICollectionView!

    private let itemRepository = ItemRepository()
    private let playerManager = PlayerManager.shared
    private var eventService: EventService?
    private var gachaService: GachaService?

    private var selectedGachaPack: GachaPack?

    private let colorData: [UIColor] = [.red, .purple]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup collection view
        gachaPackCollectionView.dataSource = self
        gachaPackCollectionView.delegate = self
        gachaPackCollectionView.allowsSelection = true

        // Initialize services
        let context = DataManager.shared.viewContext
        let itemRepository = ItemRepository()
        let eventService = EventService(itemRepository: itemRepository, context: context)

        // Initialize Gacha Service
        gachaService = GachaService(
            itemRepository: itemRepository,
            eventService: eventService,
            context: context
        )

        // Select first pack by default
        selectedGachaPack = gachaService?.getAllPacks().first
        updatePackSelectorLabel()
    }

    private func updatePackSelectorLabel() {
        packSelectorLabel.text = selectedGachaPack.map {
            "Selected Pack: \($0.name) (Cost: \($0.cost))"
        } ?? "No Pack Selected"
    }

    @IBAction func gachaDrawButtonTapped(_ sender: UIButton) {
        guard let gachaService = gachaService else {
            showErrorMessage("Gacha Service not initialized")
            return
        }

        guard let selectedPack = selectedGachaPack else {
            showErrorMessage("No pack selected")
            return
        }

        // Get or create player
        var player = playerManager.getOrCreatePlayer()

        // Attempt to draw from the pack
        let drawnItems = gachaService.drawFromPack(packName: selectedPack.name, count: 1, for: &player)

        // Update player
        playerManager.addItems(drawnItems)

        // Display drawn items
        displayDrawnItems(drawnItems)
    }

    private func showErrorMessage(_ message: String) {
        gachaPackLabel.text = message
        print(message)
    }

    private func displayDrawnItems(_ items: [any IGachaItem]) {
        guard !items.isEmpty else {
            gachaPackLabel.text = "No items drawn."
            return
        }

        let itemDescriptions = items.map { item in
            "\(item.name) [\(item.rarity.rawValue.capitalized)]"
        }.joined(separator: ", ")

        gachaPackLabel.text = "Drawn: \(itemDescriptions)"
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension GachaViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        gachaService?.getAllPacks().count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)

        // Alternate background colors
        cell.backgroundColor = colorData[indexPath.item % colorData.count]

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let packs = gachaService?.getAllPacks() else { return }

        let selectedPack = packs[indexPath.item]
        selectedGachaPack = selectedPack
        updatePackSelectorLabel()

        // Animate selected cell
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        // Reset initial state
        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowOpacity = 0.0
        cell.layer.shadowRadius = 0
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        // Animate to final state
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
            cell.transform = .identity
            cell.layer.shadowOpacity = 0.3
            cell.layer.shadowRadius = 5
        }, completion: nil)
    }
}
