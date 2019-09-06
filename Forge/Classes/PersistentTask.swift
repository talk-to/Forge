
import Foundation

struct PersistentTask {
  let uniqueID: String
  let countOfRetries: Int
  let task: Task
  let delay: TimeInterval

  static func uniqueString() -> String {
    return UUID().uuidString
  }

  init(uniqueID: String, task: Task, delay: TimeInterval, countOfRetries: Int = 0) {
    self.uniqueID = uniqueID
    self.task = task
    self.countOfRetries = countOfRetries
    self.delay = delay
  }
}
