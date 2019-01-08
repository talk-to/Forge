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

class ForgeTestsTests: XCTestCase {

  override func setUp() {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testForgeCanBeInitialised() {
    XCTAssertNotNil(Forge(with: "test"))
  }


  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }

}
