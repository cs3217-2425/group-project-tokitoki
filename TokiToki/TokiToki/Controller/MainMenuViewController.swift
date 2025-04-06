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
        // navigationController?.pushViewController(viewController, animated: true)
        present(viewController, animated: true, completion: nil)
    }
    // Navigation actions (connect to storyboard)
    @IBAction private func profileButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "ProfileScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ProfileVC")
        viewController.modalPresentationStyle = .fullScreen
        // navigationController?.pushViewController(viewController, animated: true)
        present(viewController, animated: true, completion: nil)
    }

    @IBAction private func playGameButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "BattleScreen", bundle: nil)

         // Instantiate the view controller (replace "OtherViewControllerID" with the actual storyboard ID)
         let viewController = storyboard.instantiateViewController(withIdentifier: "BattleVC")

         // Present the view controller
         viewController.modalPresentationStyle = .fullScreen

         present(viewController, animated: true, completion: nil)
    }

    @IBAction func gachaButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "GachaScreen", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "GachaScreenVC")
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }

}
