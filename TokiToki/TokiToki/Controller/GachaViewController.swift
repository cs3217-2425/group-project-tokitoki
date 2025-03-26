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
    @IBOutlet private var packSelectorLabel: UILabel!
    @IBOutlet private var gachaPackCollectionView: UICollectionView!

    private var gachaRepository = GachaRepository()
    private var gachaService: GachaService?

    private var selectedGachaPack: GachaPack?

    private let colorData: [UIColor] = [.red, .purple]

    private var currentPlayer = Player(
        id: UUID(),
        name: "NewPlayer",
        level: 1,
        experience: 0,
        currency: 500,
        statistics: Player.PlayerStatistics(totalBattles: 0, battlesWon: 0),
        lastLoginDate: Date(),
        ownedTokis: [],
        pullsSinceRare: 0
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        gachaPackCollectionView.dataSource = self
        gachaPackCollectionView.delegate = self
        gachaPackCollectionView.allowsSelection = true

        let context = DataManager.shared.viewContext
        gachaRepository.initializeData(context: context)
        gachaService = GachaService(gachaRepository: gachaRepository, context: context)
        selectedGachaPack = gachaRepository.gachaPacks.first
    }

    @IBAction func gachaDrawButtonTapped(_ sender: UIButton) {
        guard let service = gachaService else {
            print("GachaService not initialized")
            gachaPackLabel?.text = "Error: No Gacha Service."
            return
        }

        guard let packToSelectFrom = selectedGachaPack else {
            print("No pack selected")
            gachaPackLabel?.text = "Error: No pack selected."
            return
        }

        let newlyAcquired = service.drawPack(packId: packToSelectFrom.id, for: &currentPlayer)

        if newlyAcquired.isEmpty {
            gachaPackLabel?.text = "No new Tokis acquired."
            return
        }

        var resultText = ""
        for pToki in newlyAcquired {
            if let definition = gachaRepository.allTokis.first(where: { $0.id == pToki.baseTokiId }) {
                resultText += "\(definition.name) [\(definition.rarity)]"
            } else {
                resultText += " - Unknown Toki "
            }
        }

        gachaPackLabel?.text = resultText
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension GachaViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of packs: \(gachaRepository.gachaPacks.count)")
        return gachaRepository.gachaPacks.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = colorData[indexPath.item % colorData.count]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedPack = gachaRepository.gachaPacks[indexPath.item]
        print("Selected pack: \(selectedPack.name)")
        selectedGachaPack = selectedPack
        packSelectorLabel.text = "Selected Pack: \(selectedPack.name)"

        guard let cell = collectionView.cellForItem(at: indexPath) else { return }

        cell.layer.shadowColor = UIColor.black.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell.layer.shadowOpacity = 0.0
        cell.layer.shadowRadius = 0
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

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
