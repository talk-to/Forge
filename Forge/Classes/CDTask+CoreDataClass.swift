
import Foundation
import CoreData

@objc(CDTask)
class CDTask: NSManagedObject {

  class func insertTask(with id:String, managedObjectContext: NSManagedObjectContext) -> CDTask {
    let entityName = CDTask.entityName()
    return (NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedObjectContext)) as! CDTask
  }

}
