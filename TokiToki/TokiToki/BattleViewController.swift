//
//  ViewController.swift
//  TokiToki
//
//  Created by proglab on 14/3/25.
//

import UIKit

class BattleViewController: UIViewController {

    @IBOutlet weak var skill3: UIImageView!
    @IBOutlet weak var skill2: UIImageView!
    @IBOutlet weak var skill1: UIImageView!
    @IBOutlet weak var toki1: UIImageView!
    @IBOutlet weak var toki2: UIImageView!
    @IBOutlet weak var toki3: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable user interaction
        skill1.isUserInteractionEnabled = true
        
        // Create tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(skill1Pressed))
        
        // Add gesture recognizer to the image view
        skill1.addGestureRecognizer(tapGesture)
    }
    
    @objc func skill1Pressed() {
        print("Image tapped!")
        // Perform an action, e.g., navigate to another screen or show an alert
    }
}
