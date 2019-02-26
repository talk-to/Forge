//
//  CDTask+CoreDataProperties.swift
//  
//
//  Created by aditya.gh on 2/26/19.
//
//

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

  @NSManaged public var retryAt: NSDate?
  @NSManaged public var taskCoded: String?
  @NSManaged public var taskState: Int16
  @NSManaged public var type: String?
  @NSManaged public var uniqueID: String?


  @NSManaged private var countOfRetriesInternal: Int32
  public var countOfRetries: Int {
    get {
      return Int(countOfRetriesInternal)
    }
    set {
      countOfRetriesInternal = Int32(newValue)
    }
  }

  public var state: TaskState {
    get {
      return TaskState(rawValue: taskState)!
    }
    set {
      taskState = newValue.rawValue
    }
  }

}
