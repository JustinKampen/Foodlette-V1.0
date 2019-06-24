//
//  FoodletteViewController.swift
//  Foodlette
//
//  Created by Justin Kampen on 5/24/19.
//  Copyright © 2019 Justin Kampen. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class FoodletteViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    // -------------------------------------------------------------------------
    // MARK: - Outlets and Properties
    
    @IBOutlet weak var playRandomButton: UIButton!
    @IBOutlet weak var playFourPlusRatingButton: UIButton!
    @IBOutlet weak var playRandomActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playFourPlusActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var playLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var historyButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    let locationManager = CLLocationManager()
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Filter>!
    var latitude = 0.0
    var longitude = 0.0
    var filterArray: [Filter] = []
    var filterSelected: Filter!
    
    // -------------------------------------------------------------------------
    // MARK: - Core Data Fetch
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Filter> = Filter.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            filterArray = fetchedResultsController.fetchedObjects ?? []
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        toolbar.isHidden = true
        roundStyling(playRandomButton)
        roundStyling(playFourPlusRatingButton)
        setupFetchedResultsController()
        setupCollectionViewCell()
        updateEditButtonState()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        collectionView.reloadData()
        navigationItems(isEnabled: true)
        updateEditButtonState()
    }
    
    // -------------------------------------------------------------------------
    // MARK: - UI Functionality
    
    @IBAction func playRandomButtonTapped(_ sender: Any) {
        playButtonTapped(activityIndicator: playRandomActivityIndicator, categories: "all", latitude: String(latitude), longitude: String(longitude))
    }
    
    @IBAction func playFourPlusRatingButtonTapped(_ sender: Any) {
        playButtonTapped(activityIndicator: playFourPlusActivityIndicator, categories: "all", latitude: String(latitude), longitude: String(longitude))
        let controller = WinnerViewController()
        controller.minRating = 4.0
        controller.maxRating = 5.0
    }
    
    func playButtonTapped(activityIndicator: UIActivityIndicatorView, categories: String, latitude: String, longitude: String) {
        DispatchQueue.main.async {
            activityIndicator.startAnimating()
            self.navigationItems(isEnabled: false)
        }
        YelpClient.getBusinessDataFor(categories: categories, latitude: latitude, longitude: longitude) { (business, error) in
            guard let business = business else {
                self.alert(message: "Could not load Winner. Please check your connection")
                activityIndicator.stopAnimating()
                self.navigationItems(isEnabled: true)
                return
            }
            YelpModel.data = business
            DispatchQueue.main.async {
                activityIndicator.stopAnimating()
                self.performSegue(withIdentifier: "winnerSegue", sender: nil)
            }
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        if let selected = collectionView.indexPathsForSelectedItems {
            deleteSelectedFilter(at: selected)
        }
        toolbar.isHidden = true
        navigationItems(isEnabled: true)
        updateEditButtonState()
    }
    
    func deleteSelectedFilter(at indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            let filterToDelete = filterArray[indexPath.row]
            dataController.viewContext.delete(filterToDelete)
            try? dataController.viewContext.save()
            setupFetchedResultsController()
            collectionView.reloadData()
        }
    }
    
    func setupCollectionViewCell() {
        let space: CGFloat = 8.0
        let dimension: CGFloat = (view.frame.size.width - (3 * space)) / 2
        flowLayout.minimumInteritemSpacing = space
        flowLayout.sectionInset.left = space
        flowLayout.sectionInset.right = space
        flowLayout.sectionInset.top = space
        flowLayout.sectionInset.bottom = space
        flowLayout.itemSize = CGSize(width: dimension, height: 250)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        historyButton.isEnabled = !editing
        addButton.isEnabled = !editing
        playRandomButton.isEnabled = !editing
        playFourPlusRatingButton.isEnabled = !editing
        collectionView.allowsMultipleSelection = editing
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: false)
        }
        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            let cell = collectionView.cellForItem(at: indexPath) as! FoodletteFilterCell
            cell.isEditing = editing
        }
        if !editing {
            toolbar.isHidden = true
        }
    }
    
    func navigationItems(isEnabled: Bool) {
        DispatchQueue.main.async {
            self.navigationItem.leftBarButtonItem?.isEnabled = isEnabled
            self.addButton.isEnabled = isEnabled
            self.historyButton.isEnabled = isEnabled
            self.playRandomButton.isEnabled = isEnabled
            self.playFourPlusRatingButton.isEnabled = isEnabled
            self.collectionView.isUserInteractionEnabled = isEnabled
        }
    }
    
    func updateEditButtonState() {
        if filterArray.count == 0 {
            setEditing(false, animated: true)
            playLabel.text = "Play Random or select + to create a Filter"
            navigationItem.leftBarButtonItem = nil
        } else {
            playLabel.text = "Play Random or select a Filter"
            navigationItem.leftBarButtonItem = editButtonItem
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AddFilterViewController {
            controller.dataController = dataController
        } else if let controller = segue.destination as? HistoryViewController {
            controller.dataController = dataController
        } else if let controller = segue.destination as? WinnerViewController {
            controller.dataController = dataController
            controller.filterSelected = filterSelected
        }
    }
}

// -----------------------------------------------------------------------------
// MARK: - Collection View

extension FoodletteViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filter = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FoodletteFilterCell
        cell.filterNameLabel.text = filter.name
        if let imageData = filter.image {
            cell.filterImageView?.image = UIImage(data: imageData)
        }
        cell.isEditing = isEditing
        cellStyling(cell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = fetchedResultsController.object(at: indexPath)
        filterSelected = filter
        if !isEditing {
            DispatchQueue.main.async {
                let cell = collectionView.cellForItem(at: indexPath) as! FoodletteFilterCell
                cell.activityIndicator.startAnimating()
                self.navigationItems(isEnabled: false)
            }
            YelpClient.getBusinessDataFor(categories: filter.category ?? "all", latitude: String(latitude), longitude: String(longitude)) { (business, error) in
                guard let business = business else {
                    self.alert(message: "Could not load Winner. Please check your network connection")
                    return
                }
                self.navigationItems(isEnabled: false)
                YelpModel.data = business
                DispatchQueue.main.async {
                    let cell = collectionView.cellForItem(at: indexPath) as! FoodletteFilterCell
                    cell.activityIndicator.stopAnimating()
                    self.performSegue(withIdentifier: "winnerSegue", sender: nil)
                }
            }
        } else {
            self.toolbar.isHidden = false
            self.updateEditButtonState()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing {
            if let selected = collectionView.indexPathsForSelectedItems, selected.count == 0 {
                toolbar.isHidden = true
            }
        }
    }
}

// -----------------------------------------------------------------------------
// MARK: - Location Manager

extension FoodletteViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userCoordinates: CLLocationCoordinate2D = manager.location?.coordinate else {
            alert(message: "Unable to find your location")
            locationManager.stopUpdatingLocation()
            return
        }
        latitude = userCoordinates.latitude
        longitude = userCoordinates.longitude
        locationManager.stopUpdatingLocation()
    }
}
