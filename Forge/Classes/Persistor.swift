
import CoreData
import FlockSwiftUtils

fileprivate let RetryAfter: TimeInterval = 5

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
  let transformer: PersistentTaskToCDTaskTransformer

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
    transformer = PersistentTaskToCDTaskTransformer(context: context)
  }

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
    let _ = transformer.from(pTask: pTask)
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
    let request = CDTask.request()
    request.predicate = NSPredicate(format: "type == %@", type)
    do {
      return try context.fetch(request).map { transformer.reverseFrom(cdTask: $0) }
    } catch {
      assertionFailure("Couldn't get tasks")
    }
    return []
  }

  func tasksPending() -> [PersistentTask] {
    let request = CDTask.request()
    request.predicate
      = NSPredicate(format: "(retryAt <= %@) AND (taskState != %@)",
                    argumentArray: [NSDate(timeIntervalSinceNow: 0),
                                    NSNumber(value: TaskState.executing.rawValue)])
    do {
      return try context.fetch(request).map { transformer.reverseFrom(cdTask: $0) }
    } catch {
      assertionFailure("Couldn't get tasks")
    }
    return []
  }
}

extension Persistor: ExecutionDelegate {
  func start(pTask: PersistentTask) {
    let cdTask = transformer.from(pTask: pTask)
    assert(cdTask.state != .executing)
    cdTask.state = .executing
  }

  func delete(pTask: PersistentTask) {
    let cdTask = transformer.from(pTask: pTask)
    assert(cdTask.managedObjectContext! == context)
    context.delete(cdTask)
  }

  func fail(pTask: PersistentTask, increaseRetryCount: Bool) {
    let cdTask = transformer.from(pTask: pTask)
    if increaseRetryCount {
      cdTask.countOfRetries += 1
    }
    assert(cdTask.state == .executing)
    cdTask.state = .dormant
    cdTask.retryAt = Date(timeIntervalSinceNow: RetryAfter)
  }
}
