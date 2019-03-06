
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

  func from(pTask: PersistentTask) -> CDTask {
    if let cdTask = task(for: pTask) {
      return cdTask
    }
    let cdTask = CDTask.insertTask(with: pTask.uniqueID, managedObjectContext: context)
    cdTask.taskCoded = PersistentTaskToCDTaskTransformer.taskTransformer.stringRepresentation(task: pTask.task)
    cdTask.countOfRetries = 0
    cdTask.state = .unknown
    cdTask.type = pTask.task.type
    cdTask.retryAt = Date.init(timeInterval: Double(pTask.initialDelay), since: Date())
    cdTask.initialDelay = Int32(pTask.initialDelay)
    return cdTask
  }

  func reverseFrom(cdTask: CDTask) -> PersistentTask {
    let task = PersistentTaskToCDTaskTransformer.taskTransformer.task(from: cdTask.taskCoded)
    return PersistentTask(uniqueID: cdTask.uniqueID, task: task, countOfRetries: cdTask.countOfRetries, initialDelay: Int(cdTask.initialDelay))
  }
}

