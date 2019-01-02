
import Foundation

public final class Task: Codable {
  let id: String
  let type: String
  var params: Dictionary<String, String>? = nil

  init(id: String, type: String) {
    self.id = id
    self.type = type
  }
}
