//
//  TokiSelectionViewController.swift
//  TokiToki
//
//  Created by Wh Kang on 6/4/25.
//

import UIKit

class TokiSelectionViewController: UIViewController {
    
    @IBOutlet weak var tokiTableView: UITableView?
    
    // We'll read from TokiDisplay's allTokis array (which is loaded from JSON).
    // Alternatively, you can store the Toki array locally or pass it in some other way.
    private let tokis = TokiDisplay.shared.allTokis

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up the tableView dataSource and delegate
        tokiTableView?.dataSource = self
        tokiTableView?.delegate = self
    }
}

// MARK: - UITableViewDataSource

extension TokiSelectionViewController: UITableViewDataSource {
    // Number of rows = total number of Tokis loaded
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tokis.count
    }
    
    // Create each cell with the Toki name
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Use the same reuse identifier you set in the storyboard (“TokiCell”)
        let cell = tableView.dequeueReusableCell(withIdentifier: "TokiCell", for: indexPath)
        let toki = tokis[indexPath.row]
        cell.textLabel?.text = toki.name
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TokiSelectionViewController: UITableViewDelegate {
    // When the user taps on a row, select that Toki and navigate or dismiss
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedToki = tokis[indexPath.row]
        
        TokiDisplay.shared.toki = selectedToki
        
        performSegue(withIdentifier: "ShowTokiDisplay", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTokiDisplay" {
            if let destVC = segue.destination as? TokiDisplayViewController {

            }
        }
    }
}
