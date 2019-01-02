
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

  init(uniqueID: String, task: Task, countOfRetries: Int) {
    self.uniqueID = uniqueID
    self.task = task
    self.countOfRetries = countOfRetries
  }
}
