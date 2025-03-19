//
//  MainMenuViewController.swift
//  TokiToki
//
//  Created by proglab on 14/3/25.
//

import UIKit

class MainMenuViewController: UIViewController {
    @IBOutlet weak var playGameButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var gachaButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        animateLogoEntrance()
    }

    private func animateLogoEntrance() {
        
    }
 
    @IBAction func playGameButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showGameplay", sender: self)
    }

    @IBAction func gachaButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showGacha", sender: self)
    }

    @IBAction func profileButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "showProfile", sender: self)
    }
}
