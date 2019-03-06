
import Foundation

struct PersistentTask {
  let uniqueID: String
  let countOfRetries: Int
  let task: Task
  let initialDelay: Int

  init(task: Task, initialDelay: Int) {
    uniqueID = task.id
    self.task = task
    self.countOfRetries = 0
    self.initialDelay = initialDelay
  }

  init(uniqueID: String, task: Task, countOfRetries: Int, initialDelay: Int) {
    self.uniqueID = uniqueID
    self.task = task
    self.countOfRetries = countOfRetries
    self.initialDelay = initialDelay
  }
}
