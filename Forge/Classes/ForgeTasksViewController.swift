//
//  ForgeTasksViewController.swift
//  Forge
//
//  Created by aditya.gh on 2/21/19.
//

import UIKit
import CoreData

public class ForgeTasksViewController: UIViewController {

  @IBOutlet private weak var tableView: UITableView!
  private var refreshInstancesTime: Double = 5.0
  private var forgeInstances = [Forge]()
  private var forgeTasks = [CDTask]()
  private var fetchedRC = [NSFetchedResultsController<CDTask>]()
  private var numberOfInstances: Int {
    get {
      return forgeInstances.count
    }
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    syncForgeTasks(withNextCall: true)
  }

  private func syncForgeTasks(withNextCall: Bool) {
    forgeInstances = ForgeViewer.forgeInstances
    forgeTasks.removeAll()
    for index in 0..<numberOfInstances {
      let request = CDTask.request() as NSFetchRequest<CDTask>
      let sort = NSSortDescriptor(key: #keyPath(CDTask.retryAt), ascending: true)
      request.sortDescriptors = [sort]
      fetchedRC.append(NSFetchedResultsController(fetchRequest: request, managedObjectContext: forgeInstances[index].persistor.context, sectionNameKeyPath: nil, cacheName: nil))
      fetchedRC[index].delegate = self
      do {
        try fetchedRC[index].performFetch()
        guard let temp = fetchedRC[index].fetchedObjects else { return }
        forgeTasks.append(contentsOf: temp)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
    if withNextCall {
      DispatchQueue.main.asyncAfter(deadline: .now() + refreshInstancesTime) { [weak self] in
        guard let self = self else { return }
        self.syncForgeTasks(withNextCall: true)
      }
    }
  }

  @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
}

extension ForgeTasksViewController: UITableViewDelegate, UITableViewDataSource {

  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 330
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return forgeTasks.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CDTaskCell") as! CDTaskCell
    cell.configure(withObj: forgeTasks[indexPath.row])
    return cell
  }
}

extension ForgeTasksViewController: NSFetchedResultsControllerDelegate {

  public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    syncForgeTasks(withNextCall: false)
    tableView.reloadData()
  }
}
