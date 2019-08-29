
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
  let mainContext : NSManagedObjectContext
  let transformer: PersistentTaskToCDTaskTransformer

  init(UUID: String) {
    self.UUID = UUID
    // FIXME: UUID should be name of sqlite created too.
    self.persistentContainer = type(of: self).persistentContainer(UUID: UUID)
    persistentContainer.loadPersistentStores { (description, error) in
      if let error = error {
        fatalError("Failed to load Core Data stack: \(error)")
      }
      logger?.forgeVerbose("Core data stack for Forge initialised.")
    }
    context = persistentContainer.newBackgroundContext()
    mainContext = persistentContainer.viewContext
    mainContext.automaticallyMergesChangesFromParent = true
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
    context.perform { [weak self] in
      guard let self = self else { return }
      self.transformer.from(pTask: pTask)
    }
  }

  func markAllTasksReadyToExecute() {
    context.perform { [weak self] in
      guard let self = self else { return }
      let request = CDTask.request()
      do {
        try self.context.fetch(request).forEach { $0.state = .dormant }
        try self.context.save()
      } catch {
        assertionFailure("Couldn't save all tasks with dormant state")
      }
    }
  }

  func tasks(ofType type: String, completionBlockHandler: @escaping ([PersistentTask]) -> Void) {
    context.perform { [weak self] in
      guard let self = self else { return }
      let request = CDTask.request()
      request.predicate = NSPredicate(format: "type == %@", type)
      do {
        let pTasks = try self.context.fetch(request).map { self.transformer.reverseFrom(cdTask: $0) }
        completionBlockHandler(pTasks)
      } catch {
        assertionFailure("Couldn't get tasks")
      }
    }
  }

  func undoableTask(withID id: String, completionBlockHandler: @escaping (PersistentTask) -> Void) {
    context.perform { [weak self] in
      guard let self = self else { return }
      let request = CDTask.request()
      request.predicate = NSPredicate(format: "uniqueID == %@", id)
      do {
        guard let cdTask = try self.context.fetch(request).first else { return }
        let submittedAt = cdTask.submittedAt
        let delay = cdTask.delay
        let undoUpto = Date(timeInterval: Double(delay), since: submittedAt)
        let currentDate = Date()
        if undoUpto > currentDate {
          let pTask = self.transformer.reverseFrom(cdTask: cdTask)
          completionBlockHandler(pTask)
        }
      } catch {
        assertionFailure("Couldn't get tasks")
      }
    }
  }

  func tasksPending(completionBlockHandler: @escaping ([PersistentTask]) -> Void) {
    context.perform {
      let request = CDTask.request()
      request.predicate
        = NSPredicate(format: "(retryAt <= %@) AND (taskState != %@)",
                      argumentArray: [NSDate(timeIntervalSinceNow: 0),
                                      NSNumber(value: TaskState.executing.rawValue)])
      request.sortDescriptors = [NSSortDescriptor(key: "submittedAt", ascending: true)]
      do {
        let pTasks = try self.context.fetch(request).map { self.transformer.reverseFrom(cdTask: $0) }
        completionBlockHandler(pTasks)
      } catch {
        assertionFailure("Couldn't get tasks")
      }
    }
  }

  func delete(id: String) {
    context.perform { [weak self] in
      guard let self = self else { return }
      let request = CDTask.request()
      let tasks: [CDTask]
      request.predicate = NSPredicate(format: "uniqueID == %@", id)
      do {
        tasks = try self.context.fetch(request)
        if !tasks.isEmpty {
          self.context.delete(tasks[0])
          self.context.saveNow()
        }
      } catch {
        assertionFailure("Couldn't get tasks")
      }
    }
  }
}

extension Persistor: ExecutionDelegate {
  func start(pTask: PersistentTask) {
    logger?.forgeInfo("Forge : Persistor will transition task(\(pTask) to executing state)")
    context.perform { [weak self] in
      guard let self = self else { return }
      let cdTask = self.transformer.from(pTask: pTask)
      assert(cdTask.state != .executing)
      cdTask.state = .executing
      self.context.saveNow()
    }
  }

  func delete(pTask: PersistentTask) {
    logger?.forgeInfo("Forge : Persistor will delete task(\(pTask))")
    context.perform { [weak self] in
      guard let self = self else { return }
      let cdTask = self.transformer.from(pTask: pTask)
      assert(cdTask.managedObjectContext! == self.context)
      self.context.delete(cdTask)
      self.context.saveNow()
      
    }
  }

  func fail(pTask: PersistentTask, increaseRetryCount: Bool) {
    logger?.forgeInfo("Forge : Persistor will transition task(\(pTask) to Dormant state)")
    context.perform { [weak self] in
      guard let self = self else { return }
      let cdTask = self.transformer.from(pTask: pTask)
      if increaseRetryCount {
        cdTask.countOfRetries += 1
      }
      assert(cdTask.state == .executing)
      cdTask.state = .dormant
      cdTask.retryAt = Date(timeIntervalSinceNow: RetryAfter)
      self.context.saveNow()
    }
  }
}
