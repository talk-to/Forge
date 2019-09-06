
import Foundation
import CoreData

fileprivate struct TaskTransformer {
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()

  private let encoding = String.Encoding.utf8

  func stringRepresentation(task: Task) -> String {
    let taskData = try! encoder.encode(task)
    return String(data: taskData, encoding: encoding)!
  }

  func task(from repr: String) -> Task {
    return try! decoder.decode(Task.self, from: repr.data(using: encoding)!)
  }
}

struct PersistentTaskToCDTaskTransformer {
  static private let taskTransformer = TaskTransformer()

  private let context: NSManagedObjectContext
  init(context: NSManagedObjectContext) {
    self.context = context
  }

  private func task(for pTask: PersistentTask) -> CDTask? {
    return CDTask.task(with: pTask.uniqueID, managedObjectContext: context)
  }

  @discardableResult func from(pTask: PersistentTask) -> CDTask {
    if let cdTask = task(for: pTask) {
      logger?.forgeInfo("Persistent task : \(pTask) converted into CDTask : \(cdTask)")
      return cdTask
    }
    let cdTask = CDTask.insertTask(with: pTask.uniqueID, managedObjectContext: context)
    cdTask.taskCoded = PersistentTaskToCDTaskTransformer.taskTransformer.stringRepresentation(task: pTask.task)
    cdTask.countOfRetries = 0
    cdTask.state = .unknown
    cdTask.type = pTask.task.type
    cdTask.retryAt = Date.init(timeInterval: pTask.delay, since: Date())
    cdTask.submittedAt = Date()
    cdTask.delay = pTask.delay
    self.context.saveNow()
    logger?.forgeInfo("Persistent task : \(pTask) converted into CDTask : \(cdTask)")
    return cdTask
  }

  func reverseFrom(cdTask: CDTask) -> PersistentTask {
    let task = PersistentTaskToCDTaskTransformer.taskTransformer.task(from: cdTask.taskCoded)
    let pTask = PersistentTask(uniqueID: cdTask.uniqueID, task: task, countOfRetries: cdTask.countOfRetries, delay: cdTask.delay)
    logger?.forgeInfo("CDTask : \(cdTask) converted into \(pTask)")
    return pTask
  }
}

