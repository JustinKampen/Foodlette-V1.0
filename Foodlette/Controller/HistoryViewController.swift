//
//  HistoryViewController.swift
//  Foodlette
//
//  Created by Justin Kampen on 5/27/19.
//  Copyright © 2019 Justin Kampen. All rights reserved.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // -------------------------------------------------------------------------
    // MARK: - Outlets and Properties
    
    @IBOutlet weak var tableView: UITableView!
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<History>!
    
    // -------------------------------------------------------------------------
    // MARK: - Core Data Fetch
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<History> = History.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "History"
        navigationItem.backBarButtonItem?.tintColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 70
        setupFetchedResultsController()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - UI Functionality
    
    func displayRatingImage(for rating: Double) -> UIImage {
        var ratingImage: UIImage {
            switch rating {
            case 0.0...0.9: return #imageLiteral(resourceName: "small_0")
            case 1.0...1.4: return #imageLiteral(resourceName: "small_1")
            case 1.5...1.9: return #imageLiteral(resourceName: "small_1_half")
            case 2.0...2.4: return #imageLiteral(resourceName: "small_2")
            case 2.5...2.9: return #imageLiteral(resourceName: "small_2")
            case 3.0...3.4: return #imageLiteral(resourceName: "small_3")
            case 3.5...3.9: return #imageLiteral(resourceName: "small_3_half")
            case 4.0...4.4: return #imageLiteral(resourceName: "small_4")
            case 4.5...4.9: return #imageLiteral(resourceName: "small_4_half")
            case 5.0: return #imageLiteral(resourceName: "small_5")
            default:
                return #imageLiteral(resourceName: "small_0")
            }
        }
        return ratingImage
    }
}

// -----------------------------------------------------------------------------
// MARK: - Table View

extension HistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let history = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! FoodletteHistoryCell
        cell.businessLabel.text = history.name
        cell.reviewCountLabel.text = history.reviewCount
        if let date = history.date {
            cell.dateLabel.text = dateFormatter.string(from: date)
        }
        cell.ratingImageView.image = displayRatingImage(for: history.rating)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let historyToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(historyToDelete)
        try? dataController.viewContext.save()
    }
}

// -----------------------------------------------------------------------------
// MARK: - Fetched Results Controller

extension HistoryViewController {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        tableView.deleteRows(at: [indexPath!], with: .fade)
    }
}
