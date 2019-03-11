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
  private var labels = [
    NSLocalizedString("Count of Retries : ", comment: "number of retries done"),
    NSLocalizedString("Retry At : ", comment: "next retry time"),
    NSLocalizedString("Task Coded : ", comment: "task in coded form"),
    NSLocalizedString("Task State : ", comment: "current task state"),
    NSLocalizedString("Type : ", comment: "task type"),
    NSLocalizedString("UniqueID : ", comment: "unique id of task"),
    NSLocalizedString("Submitted at : ", comment: "time when task was submitted"),
    NSLocalizedString("Delay : ", comment: "initial delay in seconds")
  ]
  private var labelValues = ["", "", "", "", "", "", "", ""]
  var task: CDTask!

  override func viewDidLoad() {
    super.viewDidLoad()
    setLabels(task: task)
    tableView.reloadData()
    notificationObserving()
  }

  private func notificationObserving() {
    let notificationCenter = NotificationCenter.default
    notificationCenter.addObserver (
      self,
      selector: #selector(managedObjectContextObjectsDidChange),
      name: NSNotification.Name.NSManagedObjectContextObjectsDidChange,
      object: task.managedObjectContext
    )
  }

  @objc private func managedObjectContextObjectsDidChange(notification: Notification) {
    guard let userInfo = notification.userInfo else { return }
    if let refresh = userInfo[NSRefreshedObjectsKey] as? Set<CDTask>, refresh.count > 0 {
      for refreshTask in refresh {
        if task.uniqueID == refreshTask.uniqueID {
          setLabels(task: refreshTask)
          tableView.reloadData()
        }
      }
    }
    if let updates = userInfo[NSUpdatedObjectsKey] as? Set<CDTask>, updates.count > 0 {
      for updatedTask in updates {
        if task.uniqueID == updatedTask.uniqueID {
          setLabels(task: updatedTask)
          tableView.reloadData()
        }
      }
    }
    if let deletes = userInfo[NSDeletedObjectsKey] as? Set<CDTask>, deletes.count > 0 {
      for deletedTask in deletes {
        if task.uniqueID == deletedTask.uniqueID {
          labelValues[3] = "completed"
          tableView.reloadData()
        }
      }
    }
  }

  private func setLabels(task: CDTask) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .medium
    labelValues[0] = String(task.countOfRetries)
    labelValues[1] = dateFormatter.string(from: task.retryAt)
    labelValues[2] = task.taskCoded
    switch task.state {
    case .dormant: labelValues[3] = "dormant"
    case .executing: labelValues[3] = "executing"
    case .unknown: labelValues[3] = "unknown"
    }
    labelValues[4] = task.type
    labelValues[5] = task.uniqueID
    labelValues[6] = dateFormatter.string(from: task.submittedAt)
    labelValues[7] = String(task.delay)
  }
}

extension ForgeTaskDetailedViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return labels.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CDTaskDetailedCell") as! CDTaskDetailedCell
    cell.configure(with: labels[indexPath.row] + labelValues[indexPath.row])
    return cell
  }
}
