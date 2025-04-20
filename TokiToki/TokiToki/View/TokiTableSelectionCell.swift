//
//  TokiTableViewCell.swift
//  TokiToki
//
//  Created by Wh Kang on 15/4/25.
//

import UIKit

class TokiTableSelectionCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var selectionSwitch: UISwitch!

    // Closure to notify when the switch value changes.
    var switchValueChanged: ((Bool) -> Void)?

    // IBAction connected to the UISwitch's "Value Changed" event.
    @IBAction func switchChanged(_ sender: UISwitch) {
        switchValueChanged?(sender.isOn)
    }
}
