//
//  CDTaskCell.swift
//  Alamofire
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
    self.countOfRetriesInternal.text = "hi" + String(obj.countOfRetries)
    self.retryAt.text = "hi" + DateFormatter().string(from: obj.retryAt)
    self.taskCoded.text = "hi" + obj.taskCoded
    self.taskState.text = "hi" + obj.description
    self.type.text = "hi" + obj.type
    self.uniqueID.text = "hi" + obj.uniqueID
  }

}

extension TaskState {
  var description: String {
    switch self {
    case .unknown:
      return "unknown"
    case .executing:
      return "executing"
    case .dormant:
      return "dormant"
    default:
      return "no such case"
    }
  }
}
