//
//  TokiSelection.swift
//  TokiToki
//
//  Created by Wh Kang on 15/4/25.
//

import ObjectiveC
import UIKit

class TokiSelection {
    let tokiDisplay = TokiDisplay()
    // All available Tokis loaded from TokiDisplay.
    let tokis: [Toki]
    // Array to hold the tokis selected for battle.
    var selectedTokis: [Toki] = []
    
    init() {
        // Initialize the TokiDisplay to load all Tokis.
        tokis = tokiDisplay.allTokis
    }
    
    func startBattleTapped(_ vcont: UIViewController) {
        // Update the global player's toki list.
        PlayerManager.shared.resetTokisForBattle()
        PlayerManager.shared.getTokisForBattle()
        for toki in selectedTokis {
            PlayerManager.shared.addTokiToBattle(toki)
            print("[TokiSelection] Added Toki: \(toki.name) to PlayerManager")
        }
        
        // Switch to the BattleScreen storyboard.
        let battleStoryboard = UIStoryboard(name: "BattleScreen", bundle: nil)
        if let battleVC = battleStoryboard.instantiateInitialViewController() {
            battleVC.modalPresentationStyle = .fullScreen
            vcont.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            vcont.navigationController?.pushViewController(battleVC, animated: true)
        }
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
        return tokis.count
    }
    
    // Dequeues and configures each cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TokiCell", for: indexPath) as? TokiTableSelectionCell else {
            return UITableViewCell()
        }
        
        let toki = tokis[indexPath.row]
        cell.nameLabel.text = toki.name
        
        // Set the switch state based on whether the toki is in selectedTokis.
        let isSelected = selectedTokis.contains { $0.id == toki.id }
        cell.selectionSwitch.setOn(isSelected, animated: false)
        
        // Configure the switch callback.
        cell.switchValueChanged = { [weak self] isOn in
            guard let self = self else { return }
            if isOn {
                if !self.selectedTokis.contains(where: { $0.id == toki.id }) {
                    self.selectedTokis.append(toki)
                    print("[TokiSelection] Added Toki: \(toki.name) to selectedTokis")
                }
            } else {
                if let index = self.selectedTokis.firstIndex(where: { $0.id == toki.id }) {
                    self.selectedTokis.remove(at: index)
                    print("[TokiSelection] Removed Toki: \(toki.name) from selectedTokis")
                }
            }
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
