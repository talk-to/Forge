
class Persistor {
  func save(task: PersistentTask) {

  }

  func completedTasks() -> [PersistentTask] {
    return []
  }

  func failedTasks() -> [PersistentTask] {
    return []
  }

  func tasks(ofType type: String) -> [PersistentTask] {
    return []
  }

  let UUID: String
  init(UUID: String) {
    self.UUID = UUID
  }

}

struct PersistentTask {
  let uniqueID: String
  let task: Task

  init(task: Task) {
    uniqueID = UUID().uuidString
    self.task = task
  }
}
