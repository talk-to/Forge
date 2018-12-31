
import Foundation
import CoreData

public enum TaskState: Int16 {
  case unknown
  case executing
  case dormant
}

extension CDTask {

  class func entityName () -> String {
    return "CDTask"
  }

  @NSManaged public var uniqueID: String
  @NSManaged public var taskCoded: String
  @NSManaged public var countOfRetries: Int32
  @NSManaged private var taskState: Int16

  public var state: TaskState {
    get {
      return TaskState(rawValue: taskState)!
    }
    set {
      taskState = newValue.rawValue
    }
  }

}
