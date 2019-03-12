
import Foundation

struct PersistentTask {
  let uniqueID: String
  let countOfRetries: Int
  let task: Task
  let delay: TimeInterval

  static func uniqueString() -> String {
    return UUID().uuidString
  }

  init(task: Task, afterDelay delay: TimeInterval, taskID: String) {
    self.uniqueID = taskID
    self.task = task
    self.countOfRetries = 0
    self.delay = delay
  }

  init(uniqueID: String, task: Task, countOfRetries: Int, delay: TimeInterval) {
    self.uniqueID = uniqueID
    self.task = task
    self.countOfRetries = countOfRetries
    self.delay = delay
  }
}
