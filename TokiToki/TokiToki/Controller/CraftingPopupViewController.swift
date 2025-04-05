//
//  CraftingPopupViewController.swift
//  TokiToki
//
//  Created by Wh Kang on 5/4/25.
//

import UIKit

class CraftingPopupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // The item we swiped "Craft" on
    var originalItem: Equipment!
    // The index of that item in the inventory
    var originalItemIndex: Int!

    // The second item the user selects from the table
    var selectedItem: Equipment?

    // We store the entire inventory except the original item
    private var availableItems: [Equipment] = []

    // Callback to refresh UI in the presenting controller
    var onCraftComplete: (() -> Void)?

    // UI
    private let tableView = UITableView()
    private let craftButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        preferredContentSize = CGSize(width: 320, height: 400)

        // 1) Build a table of all inventory items except the original
        let component = TokiDisplay.shared.equipmentFacade.equipmentComponent
        availableItems = component.inventory.filter { $0.id != originalItem.id }

        // 2) Set up table
        tableView.frame = CGRect(x: 0, y: 0, width: 320, height: 320)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)

        // 3) Add a Craft button
        craftButton.setTitle("Craft", for: .normal)
        craftButton.addTarget(self, action: #selector(craftButtonTapped), for: .touchUpInside)
        craftButton.frame = CGRect(x: 0, y: 330, width: 320, height: 44)
        view.addSubview(craftButton)
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return availableItems.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell",
                                                 for: indexPath)
        let item = availableItems[indexPath.row]
        cell.textLabel?.text = item.name
        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        selectedItem = availableItems[indexPath.row]
    }

    // MARK: - Crafting Logic
    @objc private func craftButtonTapped() {
        guard let original = originalItem else {
            return
        }
        guard let secondItem = selectedItem else {
            // Possibly alert: 'Please select an item to craft with.'
            return
        }

        let component = TokiDisplay.shared.equipmentFacade.equipmentComponent
        let itemsToCraft = [original, secondItem]

        // This returns the new item if crafting was successful, otherwise nil
        let newlyCraftedItem = TokiDisplay.shared.equipmentFacade.craftItems(items: itemsToCraft)

        // If no item was produced, it's an invalid recipe. Show alert and stop.
        guard let craftedItem = newlyCraftedItem else {
            let alert = UIAlertController(
                title: "Invalid Recipe",
                message: "No valid crafting result was produced.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                self.dismiss(animated: true, completion: nil)
            })
            present(alert, animated: true)
            return
        }

        // Crafting succeeded. Now remove the old items from Toki's equipment (the facade already removed them from inventory).
        if let eqIdx1 = TokiDisplay.shared.toki.equipment.firstIndex(where: { $0.id == original.id }) {
            TokiDisplay.shared.toki.equipment.remove(at: eqIdx1)
        }
        if let eqIdx2 = TokiDisplay.shared.toki.equipment.firstIndex(where: { $0.id == secondItem.id }) {
            TokiDisplay.shared.toki.equipment.remove(at: eqIdx2)
        }

        // Insert the newly crafted item at the original slot
        if originalItemIndex >= component.inventory.count {
            // If the original was near the end, just append
            component.inventory.append(craftedItem)
        } else {
            component.inventory.insert(craftedItem, at: originalItemIndex)
        }

        // Also insert in Toki's equipment array
        if originalItemIndex >= TokiDisplay.shared.toki.equipment.count {
            TokiDisplay.shared.toki.equipment.append(craftedItem)
        } else {
            TokiDisplay.shared.toki.equipment.insert(craftedItem, at: originalItemIndex)
        }

        // Save + refresh UI
        TokiDisplay.shared.equipmentFacade.equipmentComponent = component
        ServiceLocator.shared.dataStore.save()

        onCraftComplete?()
        dismiss(animated: true, completion: nil)
    }
}
