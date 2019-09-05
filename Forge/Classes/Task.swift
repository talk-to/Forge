
import Foundation

fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()

public final class Task: Codable {
  public let id: String
  public let type: String
  let paramsData: Data

  public func params<T>(_ type: T.Type) throws -> T where T: Codable {
    return try decoder.decode(type, from: paramsData)
  }

  public init<T: Codable>(id: String, type: String, params: T) throws {
    self.id = id
    self.type = type
    self.paramsData = try encoder.encode(params)
  }
  
  public var description: String {
    return "Task(id: \(self.id), type: \(self.type))"
  }
  
}
