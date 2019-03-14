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
  private var labelDict = [String : String]()
  private var labelKey = [String]()
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
          labelDict["Task State"] = "completed"
          tableView.reloadData()
        }
      }
    }
  }

  private func setLabels(task: CDTask) {
    labelDict.removeAll()
    labelKey.removeAll()
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .none
    dateFormatter.timeStyle = .medium
    labelDict["Count of Retries"] = String(task.countOfRetries)
    labelDict["Retry At"] = dateFormatter.string(from: task.retryAt)
    labelDict["Task Coded"] = task.taskCoded
    switch task.state {
    case .dormant: labelDict["Task State"] = "dormant"
    case .executing: labelDict["Task State"] = "executing"
    case .unknown: labelDict["Task State"] = "unknown"
    }
    labelDict["Type"] = task.type
    labelDict["UniqueID"] = task.uniqueID
    labelDict["Submitted at"] = dateFormatter.string(from: task.submittedAt)
    labelDict["Delay"] = String(task.delay)
    for it in labelDict {
      labelKey.append(it.key)
    }
  }
}

extension ForgeTaskDetailedViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return labelDict.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CDTaskDetailedCell") as! CDTaskDetailedCell
    cell.configure(with: labelKey[indexPath.row] + " : " +  labelDict[labelKey[indexPath.row]]!)
    return cell
  }
}
