
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

  class func task(with id: String, managedObjectContext: NSManagedObjectContext) -> CDTask? {
    let fetchRequest = CDTask.request()
    fetchRequest.predicate = NSPredicate(format: "uniqueID == %@", id)
    fetchRequest.fetchLimit = 1
    do {
      return try managedObjectContext.fetch(fetchRequest).first
    } catch {
      logger?.forgeError("Got error \(error)")
      return nil
    }
  }
  
  override public var description: String {
    return "CDTask(uniqueID: \(self.uniqueID), type: \(self.type), retryAt: \(self.retryAt), submittedAt: \(self.submittedAt), delay: \(self.delay))"
  }

}
