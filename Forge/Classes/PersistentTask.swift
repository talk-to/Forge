
import Foundation

struct PersistentTask {
  let uniqueID: String
  let task: Task

  init(task: Task) {
    uniqueID = UUID().uuidString
    self.task = task
  }
}

//class PersistentTaskValueTransformer: ValueTransformer {
//  override func transformedValue(_ value: Any?) -> Any? {
//    guard let v = value else {
//      return nil
//    }
//    return NSKeyedArchiver.archivedData(withRootObject: v)
//  }
//
//  override func reverseTransformedValue(_ value: Any?) -> Any? {
//    guard let v = value as? Data else {
//      return nil
//    }
//    return NSKeyedUnarchiver.unarchiveObject(with: v)
//  }
//
//  override class func allowsReverseTransformation() -> Bool {
//    return true
//  }
//}
