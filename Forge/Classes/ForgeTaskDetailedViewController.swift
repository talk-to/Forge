//
//  ForgeTaskDetailedViewController.swift
//  Forge
//
//  Created by aditya.gh on 2/25/19.
//

import UIKit
import CoreData

class ForgeTaskDetailedViewController: UIViewController {

  @IBOutlet private weak var countOfRetriesInternal: UILabel!
  @IBOutlet private weak var retryAt: UILabel!
  @IBOutlet private weak var taskCoded: UILabel!
  @IBOutlet private weak var taskState: UILabel!
  @IBOutlet private weak var type: UILabel!
  @IBOutlet private weak var uniqueID: UILabel!
  var forgeInstance: Forge?
  var taskUniqueID: String?
  private var fetchedRC: NSFetchedResultsController<CDTask>!

  override func viewDidLoad() {
    super.viewDidLoad()
    getContext()
  }

  private func getContext() {

    guard let forgeInstance = forgeInstance else { return }
    guard let taskUniqueID = taskUniqueID else { return }
    let request = CDTask.request() as NSFetchRequest<CDTask>
    let sort = NSSortDescriptor(key: #keyPath(CDTask.retryAt), ascending: true)
    request.sortDescriptors = [sort]
    fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: forgeInstance.persistor.context, sectionNameKeyPath: nil, cacheName: nil)
    fetchedRC.delegate = self as? NSFetchedResultsControllerDelegate
    do {
      try fetchedRC.performFetch()
      guard let forgeTasksForThisInstance = fetchedRC.fetchedObjects else { return }
      var isTaskCompleted = true
      for task in forgeTasksForThisInstance {
        if task.uniqueID == taskUniqueID {
          setupView(with: task)
          isTaskCompleted = false
        }
      }
      if isTaskCompleted {
        taskState.text = "Task State: Completed"
        taskState.textColor = UIColor(red: 0.rgb, green: 128.rgb, blue: 0.rgb, alpha: 1.0)
      }
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }

  private func setupView(with obj: CDTask) {
    self.countOfRetriesInternal.text = "countOfRetriesInternal: " + String(obj.countOfRetries)
    self.countOfRetriesInternal.lineBreakMode = .byWordWrapping

    self.retryAt.text = "retryAt: " + DateFormatter().string(from: obj.retryAt)
    self.retryAt.lineBreakMode = .byWordWrapping

    self.taskCoded.text = "taskCoded: " + obj.taskCoded
    self.taskCoded.lineBreakMode = .byWordWrapping

    switch obj.state {
    case .dormant: self.taskState.text = "taskState: dormant"
    case .executing: self.taskState.text = "taskState: executing"
    case .unknown: self.taskState.text = "taskState: unknown"
    }
    self.taskState.lineBreakMode = .byWordWrapping

    self.type.text = "type: " + obj.type
    self.taskState.lineBreakMode = .byWordWrapping

    self.uniqueID.text = "uniqueID: " + obj.uniqueID
    self.uniqueID.lineBreakMode = .byWordWrapping
  }
  
}

extension ForgeTaskDetailedViewController: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    getContext()
  }
}
