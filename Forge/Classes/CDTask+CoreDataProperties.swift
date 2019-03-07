
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

  @nonobjc class func request() -> NSFetchRequest<CDTask> {
    return NSFetchRequest<CDTask>(entityName: entityName())
  }

  @NSManaged public var uniqueID: String
  @NSManaged public var taskCoded: String
  @NSManaged public var type: String
  @NSManaged public var retryAt: Date
  @NSManaged public var submittedAt: Date
  @NSManaged public var delay: Int32

  @NSManaged private var countOfRetriesInternal: Int32
  public var countOfRetries: Int {
    get {
      return Int(countOfRetriesInternal)
    }
    set {
      countOfRetriesInternal = Int32(newValue)
    }
  }
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
