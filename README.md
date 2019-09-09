# Forge

[![Version](https://img.shields.io/cocoapods/v/Forge.svg?style=flat)](https://cocoapods.org/pods/Forge)
[![License](https://img.shields.io/cocoapods/l/Forge.svg?style=flat)](https://cocoapods.org/pods/Forge)
[![Platform](https://img.shields.io/cocoapods/p/Forge.svg?style=flat)](https://cocoapods.org/pods/Forge)

Simple Task handler for iOS

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Example](#example)
- [Architecture](#architecture)
- [Credits](#credits)
- [License](#license)

## Features

- [x] Task persistence across app restarts
- [x] Start tasks with delay (simulating undo)
- [x] Have tasks retriable
- [x] Task viewer for debugging
- [x] extensive logging support

## Requirements

* Swift 4.2+
* iOS 11+

## Installation

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Forge into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'Forge',
```

## Example

1. Create Forge and optionally listen to changes

  ```swift
  let forge = Forge(with: "test")
  let changeManager = TestChangeManager() // An object following `ChangeManager` protocol.
  forge.changeManager = changeManager
  ```

2. Add an executor to handle tasks for a particular type

  ```swift
  let executor = TestExecutor() // An object following `Executor` protocol.
  try! forge.register(executor: executor, for: "t") // Register executor for tasks with type "t"
  ```

3. Create a task and submit to forge

  ```swift
  let params = ["params": "params"]
  let task = try! Task(id: "id", type: "t", params: params) // Create task
  forge.submit(task: task)
  ```

4. [Optional] Presenting the Forge Tasks View Controller

	1. Create the View controller

	  ```swift
	  let storyBoard = UIStoryboard(name: "ForgeTask", bundle: Bundle(for: Forge.self))
	  guard let forgeTasksVC = storyBoard.instantiateViewController(withIdentifier: "ForgeTasksViewController")
	  as? ForgeTasksViewController else {
	  fatalError("Could not instantiate TroubleshootController")
	  }
	  ```
	  
	2. Present the created ViewController in your view heirarchy.
  
Note: To give it a spin, you can use the Tests project in [Tests](Tests) folder. Run `pod install` before opening the workspace.



## Architecture

**Please read [architecture doc](doc/architecture.md) for more details.**


## Credits

* [Ayush Goel](https://github.com/ayushgoel)
* [Aditya Ghosh](https://github.com/adityaghosh996)
* [Dinesh Kumar](https://github.com/dineshflock)

## License

Forge is available under the BSD 3-Clause license. See the LICENSE file for more info.
