
import Foundation
import CoreData

extension CDTask {

  @nonobjc class func fetchRequest() -> NSFetchRequest<CDTask> {
    return NSFetchRequest<CDTask>(entityName: entityName())
  }

  class func entityName () -> String {
    return "CDTask"
  }

  @NSManaged public var uniqueID: String
  @NSManaged public var taskCoded: String
  @NSManaged public var countOfRetries: Int32

}
