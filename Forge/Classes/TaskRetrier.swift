
import Foundation

private let ExecutionTimeGap: TimeInterval = 1

class TaskRetrier {

  private let executionManager: ExecutionManager
  private let persistor: Persistor

  init(executionManager: ExecutionManager, persistor: Persistor) {
    self.executionManager = executionManager
    self.persistor = persistor
  }

  func startRetrialForTasks() {
    continiuouslyExecuteTasks()
  }

  private func continiuouslyExecuteTasks() {
    persistor.tasksPending { [weak self] (pTasks) in
      guard let self = self else { return }
      for pTask in pTasks {
        logger?.forgeInfo("Retrial of task : \(pTask)")
        self.executionManager.safeExecute(task: pTask)
      }
      DispatchQueue.main.asyncAfter(
        deadline: .now() + ExecutionTimeGap,
        execute: { [weak self] in
          self?.continiuouslyExecuteTasks()
      })
    }
  }

}
