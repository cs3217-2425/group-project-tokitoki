//
//  ProfileViewController.swift
//  TokiToki
//
//  Created by wesho on 18/3/25.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet private var playerNameLabel: UILabel!
    @IBOutlet private var playerLevelLabel: UILabel!
    @IBOutlet private var playerExperienceLabel: UILabel!
    @IBOutlet private var currencyLabel: UILabel!
    @IBOutlet private var battleStatsLabel: UILabel!

    private let playerManager = PlayerManager()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }

    private func updateUI() {
        guard let player = playerManager.getPlayer() else {
            // Create player if none exists
            _ = playerManager.getOrCreatePlayer()
            updateUI()
            return
        }

        // Update UI with player data
        playerNameLabel.text = player.name
        playerLevelLabel.text = "Level \(player.level)"

        // Experience progress
        let currentExp = player.experience
        let nextLevelExp = (player.level + 1) * 1_000
        playerExperienceLabel.text = "EXP: \(currentExp)/\(nextLevelExp)"

        // Currency
        currencyLabel.text = "\(player.currency) 💰"

        // Battle statistics
        let battleStats = playerManager.getBattleStatistics()
        battleStatsLabel.text = "Battles: \(battleStats.total) | " +
                               "Wins: \(battleStats.won) | " +
                               "Win Rate: \(String(format: "%.1f%%", battleStats.winRate))"
    }

    @IBAction private func changeNameButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(
            title: "Change Name",
            message: "Enter your new player name",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "New Name"
            if let player = self.playerManager.getPlayer() {
                textField.text = player.name
            }
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            if let newName = alert.textFields?.first?.text, !newName.isEmpty {
                self.playerManager.updatePlayerName(newName)
                self.updateUI()
            }
        })

        present(alert, animated: true)
    }
}
