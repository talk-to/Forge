//
//  ForgeTasksViewController.swift
//  Alamofire
//
//  Created by aditya.gh on 2/21/19.
//

import UIKit
import CoreData

public class ForgeTasksViewController: UIViewController {

  @IBOutlet private weak var tableView: UITableView!
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
    syncForgeTasks()
  }

  private func syncForgeTasks() {
    forgeInstances = ForgeViewer.forgeInstances
    forgeTasks.removeAll()
    for index in 0..<numberOfInstances {
      let request = CDTask.request() as NSFetchRequest<CDTask>
      let sort = NSSortDescriptor(key: #keyPath(CDTask.retryAt), ascending: true)
      request.sortDescriptors = [sort]
      fetchedRC.append(NSFetchedResultsController(fetchRequest: request, managedObjectContext: forgeInstances[index].persistor.context, sectionNameKeyPath: nil, cacheName: nil))
      do {
        try fetchedRC[index].performFetch()
        guard let temp = fetchedRC[index].fetchedObjects else { return }
        forgeTasks.append(contentsOf: temp)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
  }

  @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }


}

extension ForgeTasksViewController: UITableViewDelegate, UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return forgeTasks.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CDTaskCell") as! CDTaskCell
    cell.configure(withObj: forgeTasks[indexPath.row])
    return cell
  }
}
