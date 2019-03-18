//
//  CDTaskCell.swift
//  Forge
//
//  Created by aditya.gh on 2/22/19.
//

import UIKit

class CDTaskCell: UITableViewCell {

  @IBOutlet private weak var taskState: UILabel!
  @IBOutlet private weak var type: UILabel!
  @IBOutlet private weak var uniqueID: UILabel!
  @IBOutlet private weak var retryCount: UILabel!
  @IBOutlet private weak var retryAt: UILabel!
  static var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .medium
    return formatter
  }


  func configure(withObj obj: CDTask) {
    switch obj.state {
    case .dormant:
      self.taskState.text = NSLocalizedString("Dormant", comment: "Dormant")
      self.taskState.backgroundColor = UIColor(red: 229.rgb, green: 114.rgb, blue: 115.rgb, alpha: 1.0)
    case .executing:
      self.taskState.text = NSLocalizedString("Executing", comment: "Executing")
      self.taskState.backgroundColor = UIColor(red: 139.rgb, green: 195.rgb, blue: 74.rgb, alpha: 1.0)
    case .unknown:
      self.taskState.text = NSLocalizedString("Unknown", comment: "Unknown")
      self.taskState.backgroundColor = UIColor(red: 255.rgb, green: 202.rgb, blue: 40.rgb, alpha: 1.0)
    }
    self.type.text = obj.type
    self.uniqueID.text = obj.uniqueID
    self.retryCount.text = String(obj.countOfRetries)
    self.retryAt.text = CDTaskCell.dateFormatter.string(from: obj.retryAt)
  }
}
