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
    @IBOutlet private var tokiCustomizerButton: UIButton!

    @IBAction func tokiCustomizerButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "TokiDisplay", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "TokiSelectionVC")
        viewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(viewController, animated: true)
    }
    // Navigation actions (connect to storyboard)
    @IBAction private func profileButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "ProfileScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileVC")
        viewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction private func playGameButtonTapped(_ sender: UIButton) {
        // Create the alert controller
        let alertController = UIAlertController(title: "Select Difficulty", message: "Choose your difficulty level.", preferredStyle: .alert)
        
        // Add the difficulty options as actions
        let easyAction = UIAlertAction(title: "Easy", style: .default) { _ in
            self.navigateToBattle(difficulty: .easy)
        }
        let normalAction = UIAlertAction(title: "Normal", style: .default) { _ in
            self.navigateToBattle(difficulty: .normal)
        }
        let hardAction = UIAlertAction(title: "Hard", style: .default) { _ in
            self.navigateToBattle(difficulty: .hard)
        }
        let hellAction = UIAlertAction(title: "Hell", style: .default) { _ in
            self.navigateToBattle(difficulty: .hell)
        }
        
        // Add a cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // Add actions to the alert controller
        alertController.addAction(easyAction)
        alertController.addAction(normalAction)
        alertController.addAction(hardAction)
        alertController.addAction(hellAction)
        alertController.addAction(cancelAction)
        
        // Present the alert controller
        present(alertController, animated: true, completion: nil)
    }
    
    private func navigateToBattle(difficulty: Level) {
        let storyboard = UIStoryboard(name: "BattleScreen", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "BattleVC")
                as? BattleScreenViewController else {
            return
        }
        viewController.configureDifficulty(difficulty)
        viewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(viewController, animated: true)
    }

    @IBAction func gachaButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "GachaScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "GachaScreenVC")
        viewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(viewController, animated: true)
    }

}
