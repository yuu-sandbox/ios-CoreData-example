//
//  ViewController.swift
//  CoreDataSample
//
//  Created by 14-0254 on 2019/09/19.
//  Copyright © 2019 Yusuke Binsaki. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Person> = {
        let fetchReq: NSFetchRequest<Person> = Person.fetchRequest()
        fetchReq.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let controller = NSFetchedResultsController(fetchRequest: fetchReq,
                                                    managedObjectContext: CoreDataManager.sharedManager.context,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        do {
            try self.fetchedResultsController.performFetch()
        } catch let error {
            print("Could not fetch. \(error)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
/*
        let ctx = CoreDataManager.sharedManager.context
        let fetchReq: NSFetchRequest<Person> = Person.fetchRequest()
        do {
            let persons = try ctx.fetch(fetchReq)
            for person in persons {
                print(person.name)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error) \(error.userInfo)")
        }
 */
    }

    @IBAction func plusTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Your name",
                                   message: "Write your name",
                                   preferredStyle: UIAlertController.Style.alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let name = ac.textFields?[0].text

            let ctx = CoreDataManager.sharedManager.context
            let person = NSEntityDescription.insertNewObject(forEntityName: "Person", into: ctx) as! Person
            person.name = name
            person.age = 19
            person.birthday = Date()
            let dep = Depertment(context: ctx)
            dep.address = "machi"
            person.relationship = dep

//            CoreDataManager.sharedManager.saveContext()
            print("action handler")
//            self.tableView.reloadData()
        }))

        ac.addTextField(configurationHandler: nil)
        self.showDetailViewController(ac, sender: nil)
    }

    func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
        let person = self.fetchedResultsController.object(at: indexPath)
        
        cell.textLabel?.text = person.name
//        cell.detailTextLabel?.text = person.relationship?.address
    }
}

extension ViewController: UITableViewDelegate {
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("section \(section)")
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cell indexpath \(indexPath)")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        print("tablewView cell")
        configureCell(cell!, at: indexPath)
        return cell!
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("beginupdate")
        self.tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("endupdate")
        self.tableView.endUpdates()
    }

    // Notifies the receiver that a fetched object has been changed due to an add, remove, move, or update.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?, for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        print("notifies fetched object at \(indexPath?.row ?? 999) newAt \(newIndexPath?.row ?? 9999)")
        switch type {
        case .insert:
            print("  insert")
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            print("  delete")
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break;
        case .update:
            print("  update")
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                configureCell(cell, at: indexPath)
            }
            break;
        case .move:
            print("  move")
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;
        @unknown default:
            fatalError("cause case")
        }
    }

    // Notifies the receiver of the addition or removal of a section.
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        print("type0")
        switch type {
        case .insert:
            break
        case .delete:
            break
        case .move:
            break
        case .update:
            break
        @unknown default:
            break
        }
    }
}
