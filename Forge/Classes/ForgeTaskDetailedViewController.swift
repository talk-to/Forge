//
//  ForgeTaskDetailedViewController.swift
//  Forge
//
//  Created by aditya.gh on 2/25/19.
//

import UIKit
import CoreData

class ForgeTaskDetailedViewController: UIViewController {

  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var countOfRetriesInternal: UILabel!
  @IBOutlet private weak var retryAt: UILabel!
  @IBOutlet private weak var taskCoded: UILabel!
  @IBOutlet private weak var taskState: UILabel!
  @IBOutlet private weak var type: UILabel!
  @IBOutlet private weak var uniqueID: UILabel!
  private var labels = ["Count of Retries : ", "Retry At : ", "Task Coded : ", "Task State : ", "Type : ", "UniqueID : ", "Undo after : "]
  private var labelValues = ["", "", "", "", "", "", ""]
  var forgeInstance: Forge?
  var taskUniqueID: String?
  private var fetchedRC: NSFetchedResultsController<CDTask>!

  override func viewDidLoad() {
    super.viewDidLoad()
    setupNFRC()
    getCDTask()
  }

  private func setupNFRC() {
    guard let forgeInstance = forgeInstance else { return }
    guard let taskUniqueID = taskUniqueID else { return }
    let request = CDTask.request() as NSFetchRequest<CDTask>
    request.predicate = NSPredicate(format: "uniqueID == %@", taskUniqueID)
    let sort = NSSortDescriptor(key: #keyPath(CDTask.retryAt), ascending: true)
    request.sortDescriptors = [sort]
    fetchedRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: forgeInstance.persistor.context, sectionNameKeyPath: nil, cacheName: nil)
    fetchedRC.delegate = self as? NSFetchedResultsControllerDelegate
  }

  private func getCDTask() {
    do {
      try fetchedRC.performFetch()
      guard let forgeTasksForThisInstance = fetchedRC.fetchedObjects else { return }
      if forgeTasksForThisInstance.isEmpty {
        labelValues[3] = "completed"
      } else {
        setupLabels(with: forgeTasksForThisInstance[0])
      }
    } catch let error as NSError {
      print("Could not fetch. \(error), \(error.userInfo)")
    }
  }

  private func setupLabels(with obj: CDTask) {
    labelValues[0] = String(obj.countOfRetries)
    labelValues[1] = DateFormatter().string(from: obj.retryAt)
    labelValues[2] = obj.taskCoded
    switch obj.state {
    case .dormant: labelValues[3] = "dormant"
    case .executing: labelValues[3] = "executing"
    case .unknown: labelValues[3] = "unknown"
    }
    labelValues[4] = obj.type
    labelValues[5] = obj.uniqueID
    labelValues[6] = String(obj.undoTime)
  }
  
}

extension ForgeTaskDetailedViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 7
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CDTaskDetailedCell") as! CDTaskDetailedCell
    cell.configure(with: labels[indexPath.row] + labelValues[indexPath.row])
    return cell
  }

  
}

extension ForgeTaskDetailedViewController: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    getCDTask()
    tableView.reloadData()
  }
}

