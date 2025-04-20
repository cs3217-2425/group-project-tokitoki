//
//  TokiSelection.swift
//  TokiToki
//
//  Created by Wh Kang on 15/4/25.
//

import ObjectiveC
import UIKit

class TokiSelection {
    let logger = Logger(subsystem: "TokiSelection")
    let tokiDisplay = TokiDisplay()
    // All available Tokis loaded from TokiDisplay.
    let tokis: [Toki]
    // Array to hold the tokis selected for battle.
    var selectedTokis: [Toki] = []
    let MAX_SELECTED_TOKIS = 3

    init() {
        // Initialize the TokiDisplay to load all Tokis.
        tokis = tokiDisplay.allTokis
    }

    func startBattleTapped(_ vcont: UIViewController) {
        // Update the global player's toki list.
        PlayerManager().resetTokisForBattle()
        _ = PlayerManager().getTokisForBattle()
        for toki in selectedTokis {
            PlayerManager().addTokiToBattle(toki)
            logger.log("Added Toki: \(toki.name) to PlayerManager")
        }

        if selectedTokis.isEmpty {
            let alert = UIAlertController(title: "No Tokis Selected",
                                          message: "Please select at least one Toki to start the battle.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            vcont.present(alert, animated: true)
            return
        }

        if selectedTokis.count > MAX_SELECTED_TOKIS {
            let alert = UIAlertController(title: "Too Many Tokis",
                                          message: "You can only bring up to \(MAX_SELECTED_TOKIS) Tokis into battle.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            vcont.present(alert, animated: true)
            return
        }

        let alertController = UIAlertController(title: "Select Difficulty", message: "Choose your difficulty level.", preferredStyle: .alert)

        let easyAction = UIAlertAction(title: "Easy", style: .default) { _ in
            self.navigateToBattle(difficulty: .easy, vcont)
        }
        let normalAction = UIAlertAction(title: "Normal", style: .default) { _ in
            self.navigateToBattle(difficulty: .normal, vcont)
        }
        let hardAction = UIAlertAction(title: "Hard", style: .default) { _ in
            self.navigateToBattle(difficulty: .hard, vcont)
        }
        let hellAction = UIAlertAction(title: "Hell", style: .default) { _ in
            self.navigateToBattle(difficulty: .hell, vcont)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(easyAction)
        alertController.addAction(normalAction)
        alertController.addAction(hardAction)
        alertController.addAction(hellAction)
        alertController.addAction(cancelAction)

        vcont.present(alertController, animated: true, completion: nil)
    }

    private func navigateToBattle(difficulty: Level, _ controller: UIViewController) {
        let storyboard = UIStoryboard(name: "BattleScreen", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "BattleVC")
                as? BattleScreenViewController else {
            return
        }
        viewController.configureDifficulty(difficulty)
        viewController.modalPresentationStyle = .fullScreen
        controller.navigationController?.pushViewController(viewController, animated: true)
    }

    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTokiDisplay" {
            if let destVC = segue.destination as? TokiDisplayViewController {
                destVC.tokiDisplay = self.tokiDisplay
                destVC.modalPresentationStyle = .fullScreen
            }
        }
    }
}

extension TokiSelection {
    // Returns the total number of Tokis.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tokis.count
    }

    // Dequeues and configures each cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = tableView.dequeueReusableCell(
              withIdentifier: "TokiCell",
              for: indexPath
            ) as? TokiTableSelectionCell else {
        return UITableViewCell()
      }

      let toki = tokis[indexPath.row]
      cell.nameLabel.text = toki.name

      // 1) Is this one already selected?
      let isSelected = selectedTokis.contains { $0.id == toki.id }

      // 2) Set the switch to match your model
      cell.selectionSwitch.setOn(isSelected, animated: false)

      // 3) Disable it if we've already got 3 and this Toki isn't among them
      cell.selectionSwitch.isEnabled = isSelected || selectedTokis.count < 3

      // 4) Capture the tableView and cell for use in the closure
      let tv = tableView
      cell.switchValueChanged = { [weak self, weak cell] isOn in
        guard let self = self, let cell = cell else { return }

        if isOn {
          // Trying to turn on…
          if self.selectedTokis.count < 3 {
            // OK, append it
            self.selectedTokis.append(toki)
            self.logger.log("Added Toki: \(toki.name) to selectedTokis")
          } else {
            // At limit → revert the toggle
            cell.selectionSwitch.setOn(false, animated: true)
            // Optionally, show an alert here to explain why
            return
          }
        } else {
          // Turning off → remove it
          if let idx = self.selectedTokis.firstIndex(where: { $0.id == toki.id }) {
            self.selectedTokis.remove(at: idx)
            self.logger.log("Removed Toki: \(toki.name) from selectedTokis")
          }
        }

        // Refresh to enable/disable other switches as needed
        tv.reloadData()
      }

      return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath, _ vcont: UIViewController) {
        let selectedToki = tokis[indexPath.row]
        // Set the toki for display using TokiDisplay.
        tokiDisplay.toki = selectedToki
        // Perform the segue to show the toki display.
        vcont.performSegue(withIdentifier: "ShowTokiDisplay", sender: self)
        // Deselect the cell for UI clarity.
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
