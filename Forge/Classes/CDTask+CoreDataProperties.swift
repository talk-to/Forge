
import Foundation
import CoreData

extension CDTask {

  class func entityName () -> String {
    return "CDTask"
  }

  @NSManaged public var uniqueID: String
  @NSManaged public var taskCoded: String
  @NSManaged public var countOfRetries: Int32

}
