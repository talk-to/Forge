
class Persistor {
  func save(task: Task) {

  }

  func completedTasks() -> [Task] {
    return []
  }

  func failedTasks() -> [Task] {
    return []
  }

  func tasks(with id: IDType) -> [Task] {
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
