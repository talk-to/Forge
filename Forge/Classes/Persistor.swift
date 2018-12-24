
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
}

struct PersistentTask {
  let task: Task
  let uniqueID: String
}
