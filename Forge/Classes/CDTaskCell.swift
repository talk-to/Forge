//
//  CDTaskCell.swift
//  Forge
//
//  Created by aditya.gh on 2/22/19.
//

import UIKit

class CDTaskCell: UITableViewCell {

  @IBOutlet weak var taskState: UILabel!
  @IBOutlet weak var type: UILabel!
  @IBOutlet weak var uniqueID: UILabel!

  func configure(withObj obj: CDTask) {
    switch obj.state {
    case .dormant: self.taskState.text = "dormant"
    case .executing: self.taskState.text = "executing"
    case .unknown: self.taskState.text = "unknown"
    }
    self.taskState.lineBreakMode = .byWordWrapping

    self.type.text = obj.type
    self.taskState.lineBreakMode = .byWordWrapping

    self.uniqueID.text = obj.uniqueID
    self.uniqueID.lineBreakMode = .byWordWrapping

  }

}
