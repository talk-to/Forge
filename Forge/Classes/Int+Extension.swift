//
//  Int+Extension.swift
//  Pods
//
//  Created by Ayush Goel on 9/9/19.
//

import Foundation

extension Int {
  /**
   Returns a CGFloat *ranging from 0-1* value that can be used while creating a UIColor from Red, Green and Blue.
   - Example:
   This example shows how to use rgb extension on Int for color *(31,32,53)*
   ```
   let color = UIColor(red: 31.rgb, green: 32.rgb, blue: 53.rgb, alpha: 1)
   ```
   */
  public var rgb: CGFloat {
    return CGFloat(Double(self)/255.0)
  }
}
