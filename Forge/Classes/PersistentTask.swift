
import Foundation

struct PersistentTask {
  let uniqueID: String
  let task: Task

  init(task: Task) {
    uniqueID = UUID().uuidString
    self.task = task
  }
}
