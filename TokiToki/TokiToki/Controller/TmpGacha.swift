//
//  GachaViewController.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//

import UIKit

class GachaViewController1: UIViewController {
    @IBOutlet private var gachaDrawButton: UIButton!
    @IBOutlet private var gachaPackLabel: UILabel!
    @IBOutlet private var packSelectorLabel: UILabel!
    private var gachaPackCollectionViewController: CollectionViewController!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let gachaPackCollectionViewController = segue.destination as? CollectionViewController {
            self.gachaPackCollectionViewController = gachaPackCollectionViewController
        }
    }
    
    private let itemRepository = ItemRepository()
    private let playerManager = PlayerManager.shared
    private var eventService: EventService?
    private var gachaService: GachaService?

    private var selectedGachaPack: GachaPack?

    private let colorData: [UIColor] = [.red, .purple]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
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


