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
  private var tuple = [(forge: Forge, nfrc: NSFetchedResultsController<CDTask>)]()
  private var timer: Timer!

  override public func viewDidLoad() {
    super.viewDidLoad()
    fetchAndReloadTable()
  }

  public override func viewWillAppear(_ animated: Bool) {
    timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(3), repeats: true) { [weak self] t in
      guard let strongSelf = self else { return }
      strongSelf.fetchAndReloadTable()
    }
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    timer.invalidate()
  }

  private func fetchAndReloadTable() {
    syncForgeInstances()
    tableView.reloadData()
  }

  // Adds new forgeInstances, creates their NFRC and their tasks
  // Assumption: Forge objects are never removed
  private func syncForgeInstances() {
    if tuple.count != ForgeViewer.forgeInstances.count {
      let len = tuple.count
      for index in len..<ForgeViewer.forgeInstances.count {
        let newInstance = ForgeViewer.forgeInstances[index]
        let request = CDTask.request() as NSFetchRequest<CDTask>
        let sort = NSSortDescriptor(key: #keyPath(CDTask.retryAt), ascending: true)
        request.sortDescriptors = [sort]
        let nfrc = NSFetchedResultsController (
          fetchRequest: request,
          managedObjectContext: newInstance.persistor.mainContext,
          sectionNameKeyPath: nil,
          cacheName: nil
        )
        nfrc.delegate = self
        tuple.append((newInstance, nfrc))
        do {
          try tuple[index].nfrc.performFetch()
        } catch let error as NSError {
          logger?.verbose("Could not fetch. \(error), \(error.userInfo)")
        }
      }
    }
  }

  private func syncParticularForgeInstanceAt(index: Int) {
    do {
      try tuple[index].nfrc.performFetch()
    } catch let error as NSError {
      logger?.verbose("Could not fetch. \(error), \(error.userInfo)")
    }
  }

  public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let forgeDetailedTaskVC = segue.destination as! ForgeTaskDetailedViewController
    forgeDetailedTaskVC.task = (sender as! CDTask)
  }

  @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
    dismiss(animated: true, completion: nil)
  }
}

extension ForgeTasksViewController: UITableViewDelegate, UITableViewDataSource {

  public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 170
  }

  public func numberOfSections(in tableView: UITableView) -> Int {
    return tuple.count
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tuple[section].nfrc.fetchedObjects?.count ?? 0
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CDTaskCell") as! CDTaskCell
    cell.configure(withObj: (tuple[indexPath.section].nfrc.fetchedObjects![indexPath.row]))
    return cell
  }

  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    performSegue (
      withIdentifier: "forgeTaskSegue",
      sender: tuple[indexPath.section].nfrc.fetchedObjects![indexPath.row]
    )
  }

}

extension ForgeTasksViewController: NSFetchedResultsControllerDelegate {

  public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    for index in 0..<tuple.count {
      if controller == tuple[index].nfrc {
        syncParticularForgeInstanceAt(index: index)
        tableView.reloadData()
        break
      }
    }
  }
}
