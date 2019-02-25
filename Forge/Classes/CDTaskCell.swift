//
//  CDTaskCell.swift
//  Forge
//
//  Created by aditya.gh on 2/22/19.
//

import UIKit

class CDTaskCell: UITableViewCell {

  @IBOutlet weak var countOfRetriesInternal: UILabel!
  @IBOutlet weak var retryAt: UILabel!
  @IBOutlet weak var taskCoded: UILabel!
  @IBOutlet weak var taskState: UILabel!
  @IBOutlet weak var type: UILabel!
  @IBOutlet weak var uniqueID: UILabel!

  func configure(withObj obj: CDTask) {
    switch obj.state {
    case .dormant: self.taskState.text = "taskState: dormant"
    case .executing: self.taskState.text = "taskState: executing"
    case .unknown: self.taskState.text = "taskState: unknown"
    }
    self.taskState.lineBreakMode = .byWordWrapping

    self.type.text = "type: " + obj.type
    self.taskState.lineBreakMode = .byWordWrapping

    self.uniqueID.text = "uniqueID: " + obj.uniqueID
    self.uniqueID.lineBreakMode = .byWordWrapping
  }

}
