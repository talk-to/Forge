
import Foundation

class ForgeViewer {

  private init(){}
  static var forgeInstances = [Forge]()
  static func addToInstances(anObject: Forge) {
    forgeInstances.append(anObject)
  }
}
