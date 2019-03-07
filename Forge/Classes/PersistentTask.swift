
import Foundation

struct PersistentTask {
  let uniqueID: String
  let countOfRetries: Int
  let task: Task
  let delay: Int

  init(task: Task, afterDelay delay: Int, taskID: String) {
    self.uniqueID = taskID
    self.task = task
    self.countOfRetries = 0
    self.delay = delay
  }

  init(uniqueID: String, task: Task, countOfRetries: Int, delay: Int) {
    self.uniqueID = uniqueID
    self.task = task
    self.countOfRetries = countOfRetries
    self.delay = delay
  }
}
