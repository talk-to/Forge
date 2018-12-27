
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
    let fetchRequest = NSFetchRequest<CDTask>(entityName: entityName())
    fetchRequest.predicate = NSPredicate(format: "uniqueID == %@", id)
    fetchRequest.fetchLimit = 1
    do {
      return try managedObjectContext.fetch(fetchRequest).first
    } catch {
      print("Got error \(error)")
      return nil
    }
  }

}
