
import Foundation

private let ExecutionTimeGap = 1

class TaskRetrier {

  private let executionManager: ExecutionManager
  private let persistor: Persistor

  init(executionManager: ExecutionManager, persistor: Persistor) {
    self.executionManager = executionManager
    self.persistor = persistor
  }

  private var repeatingTimer: Timer?

  func startRetrialForTasks() {
    if repeatingTimer == nil {
      repeatingTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(ExecutionTimeGap), repeats: true) { [weak self] t in
        guard let strongSelf = self else {
          print("Retrier deallocated, stopping..")
          return
        }
        strongSelf.executeTasks()
      }
    }
  }

  deinit {
    repeatingTimer?.invalidate()
  }

  private func executeTasks() {
    persistor.tasksPending()
      .forEach { pTask in
        executionManager.safeExecute(task: pTask)
    }
  }

}
