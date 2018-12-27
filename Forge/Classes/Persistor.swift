
import CoreData

class Persistor {

  static func persistentContainer(UUID: String) -> NSPersistentContainer {
    guard let bundlePath = Bundle(for: Persistor.self).path(forResource: "Forge", ofType: "bundle"), // defined in podspec
      let forgeBundle = Bundle(path: bundlePath),
      let modelURL = forgeBundle.url(forResource: "forge", withExtension: "momd") else {
        fatalError("Failed to get model URL for forge.")
    }
    guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
      fatalError("Failed to create model from model URL for forge.")
    }
    return NSPersistentContainer(name: UUID, managedObjectModel: model)
  }

  let UUID: String
  let persistentContainer: NSPersistentContainer
  let context: NSManagedObjectContext

  init(UUID: String) {
    self.UUID = UUID
    // FIXME: UUID should be name of sqlite created too.
    self.persistentContainer = type(of: self).persistentContainer(UUID: UUID)
    persistentContainer.loadPersistentStores { (description, error) in
      if let error = error {
        fatalError("Failed to load Core Data stack: \(error)")
      }
      print("Core data stack for Forge initialised.")
    }
    context = persistentContainer.newBackgroundContext()
  }
}

extension Persistor {
  func save(task: PersistentTask) {

  }

  func tasks(ofType type: String) -> [PersistentTask] {
    return []
  }
}

extension Persistor: ExecutionDelegate {
  func delete(task: PersistentTask) {

  }

  func fail(task: PersistentTask, increaseRetryCount: Bool) {

  }
}
