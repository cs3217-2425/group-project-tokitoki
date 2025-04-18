//
//  CraftingPopupViewController.swift
//  TokiToki
//
//  Created by Wh Kang on 5/4/25.
//

import UIKit

class CraftingPopupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tokiDisplay: TokiDisplay?  // New dependency property

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
        
        guard let tokiDisplay = tokiDisplay else {
            return
        }

        // 1) Build a table of all inventory items except the original
        let component = tokiDisplay.equipmentFacade.equipmentComponent
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
        availableItems.count
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
        guard let tokiDisplay = tokiDisplay else {
            return
        }

        let component = tokiDisplay.equipmentFacade.equipmentComponent
        let itemsToCraft = [original, secondItem]

        // This returns the new item if crafting was successful, otherwise nil
        let newlyCraftedItem = tokiDisplay.equipmentFacade.craftItems(items: itemsToCraft)

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
        if let eqIdx1 = tokiDisplay.toki.equipments.firstIndex(where: { $0.id == original.id }) {
            tokiDisplay.toki.equipments.remove(at: eqIdx1)
            PlayerManager.shared.getEquipmentComponent()
                .inventory.removeAll(where: { $0.id == original.id })
        }
        if let eqIdx2 = tokiDisplay.toki.equipments.firstIndex(where: { $0.id == secondItem.id }) {
            tokiDisplay.toki.equipments.remove(at: eqIdx2)
        }
        PlayerManager.shared.getEquipmentComponent()
            .inventory.removeAll(where: { $0.id == original.id })
        PlayerManager.shared.getEquipmentComponent()
            .inventory.removeAll(where: { $0.id == secondItem.id })

        // Also insert in Toki's equipment array
        if originalItemIndex >= tokiDisplay.toki.equipments.count {
            tokiDisplay.toki.equipments.append(craftedItem)
        } else {
            tokiDisplay.toki.equipments.insert(craftedItem, at: originalItemIndex)
        }
        PlayerManager.shared.getEquipmentComponent()
            .inventory.append(craftedItem)

        // Save + refresh UI
        tokiDisplay.equipmentFacade.equipmentComponent = component
        ServiceLocator.shared.dataStore.save()

        onCraftComplete?()
        dismiss(animated: true, completion: nil)
    }
}
