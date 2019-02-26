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
    self.taskState.lineBreakMode = .byCharWrapping

    self.type.text = NSLocalizedString(obj.type, comment: obj.type)
    self.taskState.lineBreakMode = .byCharWrapping

    self.uniqueID.text = NSLocalizedString(obj.uniqueID, comment: obj.uniqueID)
    self.uniqueID.lineBreakMode = .byCharWrapping

    self.retryCount.text = NSLocalizedString(String(obj.countOfRetries), comment: String(obj.countOfRetries))
    self.retryCount.lineBreakMode = .byCharWrapping

    self.retryAt.text = DateFormatter().string(from: obj.retryAt)
    self.retryAt.lineBreakMode = .byWordWrapping
  }

}
