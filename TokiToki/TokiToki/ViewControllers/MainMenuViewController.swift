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
        let storyboard = UIStoryboard(name: "BattleScreen", bundle: nil)

        // Instantiate the view controller (replace "OtherViewControllerID" with the actual storyboard ID)
        let viewController = storyboard.instantiateViewController(withIdentifier: "BattleVC")

        // Present the view controller
        viewController.modalPresentationStyle = .fullScreen // Optional, use if needed
        present(viewController, animated: true, completion: nil)
    }

    @IBAction private func gachaButtonTapped(_ sender: UIButton) {
    }
}
