//
//  TokiSelectionViewController.swift
//  TokiToki
//
//  Created by Wh Kang on 6/4/25.
//

import UIKit

class TokiSelectionViewController: UIViewController {
    @IBOutlet var tokiTableView: UITableView?
    @IBOutlet var startButton: UIButton?
    
    private let tokiSelection = TokiSelection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tokiTableView?.dataSource = self
        tokiTableView?.delegate = self
    }
    
    // Called when the player taps the Start button
    @IBAction func startBattleTapped(_ sender: UIButton) {
        tokiSelection.startBattleTapped(self)
    }
    
    // Preserve this segue when the cell (excluding the switch area) is tapped.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        tokiSelection.prepare(for: segue, sender: sender)
    }
}

extension TokiSelectionViewController: UITableViewDataSource {
    // Returns the total number of Tokis.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tokiSelection.tableView(tableView, numberOfRowsInSection: section)
    }
    
    // Dequeues and configures each cell.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tokiSelection.tableView(tableView, cellForRowAt: indexPath)
    }
}

extension TokiSelectionViewController: UITableViewDelegate {
    // When the cell (outside of the switch) is tapped, display the Toki details.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tokiSelection.tableView(tableView, didSelectRowAt: indexPath, self)
    }
}
