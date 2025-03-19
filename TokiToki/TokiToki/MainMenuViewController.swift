//
//  MainMenuViewController.swift
//  TokiToki
//
//  Created by wesho on 18/3/25.
//

// MainMenuViewController.swift
import UIKit

class MainMenuViewController: UIViewController {
    @IBOutlet private var profileButton: UIButton!
    @IBOutlet private var playGameButton: UIButton!
    @IBOutlet private var gachaButton: UIButton!

    // Navigation actions (connect to storyboard)
    @IBAction private func profileButtonTapped(_ sender: UIButton) {
    }

    @IBAction private func playGameButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        if let battleVC = storyboard.instantiateViewController(withIdentifier: "BattleVC") as? BattleViewController {
            battleVC.modalPresentationStyle = .fullScreen // Optional: Set presentation style
            present(battleVC, animated: true, completion: nil)
        }
        
    }

    @IBAction private func gachaButtonTapped(_ sender: UIButton) {
    }
}
