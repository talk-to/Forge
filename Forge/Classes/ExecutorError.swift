
import Foundation

public enum ExecutorError: Error {
  case NonRetriable
  case ConditionalRetriable
  case NonConditionalRetriable
}
