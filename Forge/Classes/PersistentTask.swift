
import Foundation

struct PersistentTask {
  let uniqueID: String
  let countOfRetries: Int
  let task: Task
  let undoTime: Int

  init(task: Task, _undoTime: Int) {
    uniqueID = UUID().uuidString
    self.task = task
    self.countOfRetries = 0
    self.undoTime = _undoTime
  }

  init(uniqueID: String, task: Task, countOfRetries: Int, _undoTime: Int) {
    self.uniqueID = uniqueID
    self.task = task
    self.countOfRetries = countOfRetries
    self.undoTime = _undoTime
  }
}
