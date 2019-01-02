
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
  deinit {
    do {
      try context.save()
    } catch {
      assertionFailure(error.localizedDescription)
    }
  }
}

extension Persistor {
  func save(pTask: PersistentTask) {
    let cdTask = CDTask.insertTask(with: pTask.uniqueID, managedObjectContext: context)
    cdTask.taskCoded = pTask.task.stringRepresentation()
  }

  func markAllTasksReadyToExecute() {
    let request = CDTask.request()
    do {
      try context.fetch(request).forEach { $0.state = .dormant }
      try context.save()
    } catch {
      assertionFailure("Couldn't save all tasks with dormant state")
    }
  }

  func tasks(ofType type: String) -> [PersistentTask] {
    return []
  }
}

extension Persistor: ExecutionDelegate {
  private func cdTask(for pTask: PersistentTask) -> CDTask? {
    return CDTask.task(with: pTask.uniqueID, managedObjectContext: context)
  }

  func start(pTask: PersistentTask) {
    guard let cdTask = cdTask(for: pTask) else {
      assertionFailure("Didn't find CDTask to start \(pTask)")
      return
    }
    cdTask.state = .executing
  }

  func delete(pTask: PersistentTask) {
    if let cdTask = cdTask(for: pTask) {
      cdTask.managedObjectContext?.delete(cdTask)
    } else {
      print("Could not delete task \(pTask)")
    }
  }

  func fail(pTask: PersistentTask, increaseRetryCount: Bool) {
    guard let cdTask = cdTask(for: pTask) else {
      assertionFailure("Didn't find CDTask for \(pTask)")
      return
    }
    if increaseRetryCount {
      cdTask.countOfRetries += 1
    }
    cdTask.state = .dormant
  }
}
