//
//  GachaViewController.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//

import UIKit


protocol GachaViewControllerDelegate: AnyObject {
    func didSelectPack(pack: GachaPack)
}

class GachaViewController: UIViewController {
    @IBOutlet private var gachaDrawButton: UIButton!
    @IBOutlet private var gachaPackLabel: UILabel!
    @IBOutlet private var packSelectorLabel: UILabel!
    @IBOutlet private var playerCurrencyLabel: UILabel!
    @IBOutlet private var dailyPullsCountLabel: UILabel!
    private var gachaPackCollectionViewController: CollectionViewController!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let collectionVC = segue.destination as? CollectionViewController {
            self.gachaPackCollectionViewController = collectionVC
            collectionVC.delegate = self
            
            // If packs already loaded, update the collection view
            if let packs = gachaService?.getAllPacks(), !packs.isEmpty {
                collectionVC.packs = packs
            }
        }
    }
    
    private let itemRepository = ItemRepository()
    private let playerManager = PlayerManager.shared
    private var eventService: EventService?
    private var gachaService: GachaService?

    private var selectedGachaPack: GachaPack?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let itemRepository = ItemRepository()
        let eventService = EventService(itemRepository: itemRepository)

        // Initialize Gacha Service
        gachaService = GachaService(
            itemRepository: itemRepository,
            eventService: eventService
        )
        
        // Load packs
        loadGachaPacks()
        
        // Select first pack by default
        selectedGachaPack = gachaService?.getAllPacks().first
        updatePackSelectorLabel()
        updatePlayerCurrencyLabel()
        updateDailyPullsLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatePlayerCurrencyLabel()
        updateDailyPullsLabel()
    }
    
    private func loadGachaPacks() {
        if let packs = gachaService?.getAllPacks(), !packs.isEmpty {
            // Update collection view with packs
            gachaPackCollectionViewController?.packs = packs
        }
    }

    private func updatePackSelectorLabel() {
        gachaPackLabel.text = selectedGachaPack.map {
            "Selected Pack: \($0.name) (Cost: \($0.cost))"
        } ?? "No Pack Selected"
    }
    
    private func updatePlayerCurrencyLabel() {
        let player = playerManager.getOrCreatePlayer()
        playerCurrencyLabel.text = "\(player.currency)"
        
        if let selectedPack = selectedGachaPack {
            if player.canSpendCurrency(selectedPack.cost) {
                playerCurrencyLabel.textColor = .white
            } else {
                playerCurrencyLabel.textColor = .systemRed
            }
        } else {
            playerCurrencyLabel.textColor = .white
        }
    }
    
    private func updateDailyPullsLabel() {
        let remainingPulls = playerManager.getRemainingDailyPulls()
        dailyPullsCountLabel.text = "Daily Pulls Available: \(remainingPulls)"
        
        if remainingPulls == 0 {
            dailyPullsCountLabel.textColor = .systemRed
        } else if remainingPulls <= 1 {
            dailyPullsCountLabel.textColor = .white
        } else {
            dailyPullsCountLabel.textColor = .white
        }
    }

    @IBAction func gachaDrawButtonPressed(_ sender: UIButton) {
        guard let gachaService = gachaService else {
            showErrorMessage("Gacha Service not initialized")
            return
        }

        guard let selectedPack = selectedGachaPack else {
            showErrorMessage("No pack selected")
            return
        }
        
        // Check if player has reached daily limit
        if playerManager.hasReachedDailyPullLimit() {
            showErrorMessage("Daily pull limit reached. Try again tomorrow!")
            return
        }
        
        // Get current player state to check if they can afford the pack
        let player = playerManager.getOrCreatePlayer()
        
        // Check if player has enough currency
        if !player.canSpendCurrency(selectedPack.cost) {
            showErrorMessage("Not enough currency. Need \(selectedPack.cost)")
            return
        }

        let drawnItems = playerManager.drawFromGachaPack(
            packName: selectedPack.name,
            count: 1,
            gachaService: gachaService
        )
        
        if drawnItems.isEmpty {
            showErrorMessage("No items drawn. Daily limit may have been reached.")
            return
        }
        
        // Update currency display immediately after purchase
        updatePlayerCurrencyLabel()
        
        // Update daily pulls display
        updateDailyPullsLabel()
        
        // Display drawn items
        displayDrawnItems(drawnItems)
    }

    private func showErrorMessage(_ message: String) {
        packSelectorLabel.text = message
        print(message)
        
        // Animate the label to draw attention
        UIView.animate(withDuration: 0.1, animations: {
            self.packSelectorLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                self.packSelectorLabel.transform = .identity
            }
        })
    }

    private func displayDrawnItems(_ items: [any IGachaItem]) {
        guard !items.isEmpty else {
            packSelectorLabel.text = "No items drawn."
            return
        }

        let itemDescriptions = items.map { item in
            let raritySymbol: String
            switch item.rarity {
            case .common: raritySymbol = "⚪"
            case .rare: raritySymbol = "🔵"
            case .epic: raritySymbol = "🟣"
            }
            return "\(raritySymbol) \(item.name) [\(item.rarity.rawValue.capitalized)]"
        }.joined(separator: ", ")
        
        packSelectorLabel.text = "Drawn: \(itemDescriptions)"
        
        // Play a short celebration animation for the drawn item
        playCelebrationAnimation()
    }
    
    private func playCelebrationAnimation() {
        // Create a simple particle effect for celebration
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        emitterLayer.emitterShape = .point
        emitterLayer.emitterSize = CGSize(width: 1, height: 1)
        
        let cell = CAEmitterCell()
        cell.birthRate = 20
        cell.lifetime = 1.5
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionRange = .pi * 2
        cell.scale = 0.2
        cell.scaleRange = 0.1
        cell.contents = UIImage(systemName: "star.fill")?.cgImage
        cell.color = UIColor.systemYellow.cgColor
        
        emitterLayer.emitterCells = [cell]
        view.layer.addSublayer(emitterLayer)
        
        // Remove the emitter after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            emitterLayer.removeFromSuperlayer()
        }
    }
}

// MARK: - GachaViewControllerDelegate
extension GachaViewController: GachaViewControllerDelegate {
    func didSelectPack(pack: GachaPack) {
        selectedGachaPack = pack
        updatePackSelectorLabel()
        updatePlayerCurrencyLabel()
    }
}
