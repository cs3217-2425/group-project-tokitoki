//
//  GachaViewController.swift
//  TokiToki
//
//  Created by Pawan Kishor Patil on 20/3/25.
//
import UIKit
import CoreData

class GachaViewController: UIViewController {
    @IBOutlet private var gachaDrawButton: UIButton!
    @IBOutlet private var gachaPackLabel: UILabel!
    
    // Our repository
    private var gachaRepository = GachaRepository()
    private var gachaService: GachaService?

    private var currentPlayer: Player = Player(
        id: UUID(),
        name: "NewPlayer",
        level: 1,
        experience: 0,
        currency: 500,
        statistics: Player.PlayerStatistics(totalBattles: 0, battlesWon: 0),
        lastLoginDate: Date(),
        ownedTokis: []
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1) Initialize the GachaRepository data
        let context = DataManager.shared.viewContext
        gachaRepository.initializeData(context: context)
        print("GachaRepository initialized with \(gachaRepository.allTokis.count) Tokis and \(gachaRepository.gachaPacks.count) Gacha Packs")
        
        // 2) Now that allTokis & gachaPacks are ready, create the service
        gachaService = GachaService(gachaRepository: gachaRepository, context: context)
    }
    
    @IBAction func gachaDrawButtonTapped(_ sender: UIButton) {
        print("Draw button tapped")
        guard let service = gachaService else {
            print("GachaService not initialized")
            gachaPackLabel?.text = "Error: No Gacha Service."
            return
        }

        // For this demo, pick the first pack
        guard let firstPack = gachaRepository.gachaPacks.first else {
            print("No packs in repository.")
            gachaPackLabel?.text = "No packs available."
            return
        }

        let newlyAcquired = service.drawPack(packId: firstPack.id, for: &currentPlayer)
        print("Drawn \(newlyAcquired.count) Tokis")
        if newlyAcquired.isEmpty {
            gachaPackLabel?.text = "No Toki drawn."
            return
        }

        var resultText = "Pulled from \(firstPack.name): "
        print("Result:", resultText)
        for pToki in newlyAcquired {
            print("Loading Toki \(pToki.baseTokiId)")
            if let definition = gachaRepository.allTokis.first(where: { $0.id == pToki.baseTokiId }) {
                resultText += "\(definition.name) [\(definition.rarity)] | "
            } else {
                resultText += " - Unknown Toki\n"
            }
        }

        print("resultText:", resultText)
        gachaPackLabel?.text = resultText
    }
}
