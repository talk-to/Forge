
import Foundation
import CoreData

@objc(CDTask)
class CDTask: NSManagedObject {

  class func insertTask(with id:String, managedObjectContext: NSManagedObjectContext) -> CDTask {
    let entityName = CDTask.entityName()
    let task = (NSEntityDescription.insertNewObject(forEntityName: entityName, into: managedObjectContext)) as! CDTask
    task.uniqueID = id
    return task
  }

}
