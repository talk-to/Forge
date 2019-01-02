
import Foundation

struct PersistentTask {
  let uniqueID: String
  let countOfRetries: Int
  let task: Task

  init(task: Task) {
    uniqueID = UUID().uuidString
    self.task = task
    self.countOfRetries = 0
  }
}

