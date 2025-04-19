//
//  CraftingPopupViewController.swift
//  TokiToki
//
//  Created by Wh Kang on 5/4/25.
//

import UIKit

class CraftingPopupViewController: UIViewController {
    var tokiDisplay: TokiDisplay!
    var originalItem: Equipment!
    var originalItemIndex: Int!
    var onCraftComplete: (() -> Void)?

    private var model: CraftingModel!
    private var popupView: CraftingPopupView!

    // Use loadView to set the popupView as the controller's root view
    override func loadView() {
        popupView = CraftingPopupView()
        popupView.delegate = self
        view = popupView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        preferredContentSize = CGSize(width: 320, height: 400)
        setupModel()
        // Populate items and refresh table
        popupView.items = model.availableItems
        popupView.tableView.reloadData()
    }

    private func setupModel() {
        guard let toks = tokiDisplay,
              let orig = originalItem,
              let idx = originalItemIndex else {
            fatalError("Missing dependencies for crafting popup")
        }
        model = CraftingModel(
            tokiDisplay: toks,
            originalItem: orig,
            originalItemIndex: idx
        )
    }
}

extension CraftingPopupViewController: CraftingPopupViewDelegate {
    func popupViewDidTapCraft(_ popupView: CraftingPopupView) {
        do {
            let crafted = try model.craft(withFacade: tokiDisplay.equipmentFacade)
            ServiceLocator.shared.dataStore.save()
            onCraftComplete?()
            dismiss(animated: true)
        } catch CraftingError.noSelection {
            showAlert(title: "Select Item", message: "Please choose an item to craft with.")
        } catch CraftingError.invalidRecipe {
            showAlert(title: "Invalid Recipe", message: "No valid crafting result was produced.")
        } catch {
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }

    func popupView(_ popupView: CraftingPopupView, didSelectItem item: Equipment) {
        model.selectedItem = item
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            if title == "Invalid Recipe" {
                self.dismiss(animated: true)
            }
        })
        present(alert, animated: true)
    }
}
