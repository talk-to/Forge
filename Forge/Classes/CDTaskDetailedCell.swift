//
//  CDTaskDetailedCell.swift
//  Forge
//
//  Created by aditya.gh on 2/25/19.
//

import UIKit

class CDTaskDetailedCell: UITableViewCell {
  
  @IBOutlet private weak var label: UILabel!

  func configure(with text: String) {
    label.text = text
  }
}
