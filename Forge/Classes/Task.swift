
import Foundation

public class Task: Codable {
  public let id: String
  public let type: String
  public var params: Dictionary<String, String>? = nil

  public init(id: String, type: String) {
    self.id = id
    self.type = type
  }
}
