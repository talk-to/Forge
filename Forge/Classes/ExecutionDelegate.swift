
import Foundation

protocol ExecutionDelegate: class {
  func start(pTask: PersistentTask)
  func delete(pTask: PersistentTask)
  func fail(pTask: PersistentTask, increaseRetryCount: Bool)
}
