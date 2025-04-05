//
//  CraftingPopupViewController.swift
//  TokiToki
//
//  Created by Wh Kang on 5/4/25.
//


import UIKit

import UIKit

class CraftingPopupViewController: UIViewController {

    // You can store any data you need for crafting here.
    // For example, the items that the user wants to craft:
    var itemsToCraft: [Equipment] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the basic look & feel of the popup
        view.backgroundColor = .white
        preferredContentSize = CGSize(width: 300, height: 200)

        // Add a simple label as a placeholder
        let label = UILabel()
        label.text = "Drag & Drop Crafting UI goes here."
        label.textAlignment = .center

        // Position the label in the center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // Optional: A simple 'craft' action – you can trigger this after
    // the user completes drag & drop or presses a button.
    func craftItems() {
        // Example: pass the items to the CraftingManager, etc.
        guard itemsToCraft.count >= 2 else { return }
        
        // "Craft" them
        TokiDisplay.shared.equipmentFacade.craftItems(items: itemsToCraft)
        
        // Then dismiss
        dismiss(animated: true, completion: nil)
    }
}
