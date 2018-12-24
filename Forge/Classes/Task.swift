
import Foundation

// Can not use an associatedType in @p Task since it makes `id` too generic to
// be used in TaskManager.
// Check https://stackoverflow.com/questions/36348061/protocol-can-only-be-used-as-a-generic-constraint-because-it-has-self-or-associa

//public protocol IDType: Codable, Hashable {
//}
//
//extension String: IDType {}

public protocol Task: Codable {

  init(id: String)
  var id: String { get }

}
