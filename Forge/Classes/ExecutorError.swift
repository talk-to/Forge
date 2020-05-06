
import Foundation

public enum ExecutorError: Error {
  case NonRetriable(_ errorCode: String?)
  case ConditionalRetriable
  case NonConditionalRetriable
  case Cancelled
}
