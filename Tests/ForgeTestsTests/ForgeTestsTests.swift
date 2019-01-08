//
//  ForgeTestsTests.swift
//  ForgeTestsTests
//
//  Created by Ayush Goel on 1/8/19.
//  Copyright © 2019 Flock. All rights reserved.
//

import XCTest
@testable import ForgeTests
@testable import Forge
import Result

class TestExpectation: XCTestExpectation {
  private var didFulfill = false

  var isFulfilled: Bool {
    return didFulfill
  }

  override func fulfill() {
    super.fulfill()
    didFulfill = true
  }
}

class TestChangeManager: ChangeManager {
  var willStartCalledTimes = 0
  func willStart(task: Task) {
    willStartCalledTimes += 1
  }

  var didCompleteCalledTimes = 0
  func didComplete(task: Task, result: Result<Bool, ExecutorError>) {
    didCompleteCalledTimes += 1
  }
}

class TestExecutor: Executor {
  var executedTasks = 0
  func execute(task: Task, countOfRetries: Int, completion: @escaping (Result<Bool, ExecutorError>) -> Void) {
    executedTasks += 1
    completion(Result(value: true))
  }
}

class ForgeTestsTests: XCTestCase {

  func testForgeCanBeInitialised() {
    XCTAssertNotNil(Forge(with: "test"))
  }

  func testRunningOfATask() {
    let forge = Forge(with: "test")
    let changeManager = TestChangeManager()
    forge.changeManager = changeManager
    let executor = TestExecutor()
    try! forge.register(executor: executor, for: "t")
    let task = Task(id: "id", type: "t")
    forge.submit(task: task)

    let e1 = TestExpectation(description: "changeManager will start is called")
    let e2 = TestExpectation(description: "changeManager did complete is called")
    let e3 = TestExpectation(description: "executor called")
    var times = 0
    while true {
      if changeManager.willStartCalledTimes == 1 {
        e1.fulfill()
      }
      if changeManager.didCompleteCalledTimes == 1 {
        e2.fulfill()
      }
      if executor.executedTasks == 1 {
        e3.fulfill()
      }
      if e1.isFulfilled && e2.isFulfilled && e3.isFulfilled {
        break
      }
      RunLoop.current.run(until: Date(timeIntervalSinceNow: 1))
      times += 1
      if (times >= 1) {
        XCTFail()
      }
    }
  }


  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
