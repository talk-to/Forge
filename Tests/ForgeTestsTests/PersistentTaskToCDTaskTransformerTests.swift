//
//  PersistentTaskToCDTaskTransformerTests.swift
//  ForgeTestsTests
//
//  Created by Ayush Goel on 1/15/19.
//  Copyright © 2019 Flock. All rights reserved.
//

import XCTest
@testable import Forge
import CoreData

func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
  let moduleName = "Forge"
  do {
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    let modelURL = Bundle.main.url(forResource: moduleName, withExtension:"momd")
    let newObjectModel = NSManagedObjectModel.init(contentsOf: modelURL!)
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel : newObjectModel!)
    try  persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)

    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    return managedObjectContext
  } catch {
    print(error)
    XCTFail()
  }
  XCTFail("failed to created mocked coreData (inMemroy)")
  return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
}

class PersistentTaskToCDTaskTransformerTests: XCTestCase {

  func persistentContainer(UUID: String) -> NSPersistentContainer {
    guard let bundlePath = Bundle(for: Persistor.self).path(forResource: "Forge", ofType: "bundle"), // defined in podspec
      let forgeBundle = Bundle(path: bundlePath),
      let modelURL = forgeBundle.url(forResource: "forge", withExtension: "momd") else {
        fatalError("Failed to get model URL for forge.")
    }
    guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
      fatalError("Failed to create model from model URL for forge.")
    }
    return NSPersistentContainer(name: UUID, managedObjectModel: model)
  }

  func testConversionToCDTask() {
    let container = persistentContainer(UUID: "UUID")
    container.loadPersistentStores { description, error in
      if let e = error {
        XCTFail(e.localizedDescription)
      }
    }
    let transformer = PersistentTaskToCDTaskTransformer(context: container.viewContext)

    let task = try! Task(id: "id", type: "type", params: ["params": "params"])
    let pTask = PersistentTask(uniqueID: "id", task: task, delay: 1)
    let cdTask = transformer.from(pTask: pTask)
    XCTAssertEqual(cdTask.countOfRetries, 0)
    XCTAssertEqual(cdTask.state, .unknown)
    XCTAssertEqual(cdTask.type, "type")

    let oldPTask = transformer.reverseFrom(cdTask: cdTask)
    XCTAssertEqual(oldPTask.countOfRetries, 0)
    XCTAssertEqual(oldPTask.task.type, "type")
    XCTAssertEqual(try oldPTask.task.params([String: String].self), ["params": "params"])
  }

}
