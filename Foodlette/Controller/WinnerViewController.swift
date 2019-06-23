//
//  WinnerViewController.swift
//  Foodlette
//
//  Created by Justin Kampen on 5/26/19.
//  Copyright © 2019 Justin Kampen. All rights reserved.
//

import UIKit
import MapKit

class WinnerViewController: UIViewController {
    
    // -------------------------------------------------------------------------
    // MARK: - Outlets and Properties
    
    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var businessImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var reviewCountLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var dataController: DataController!
    var filterSelected: Filter!
    var foodletteWinner: Business!
    var minRating = 0.0
    var maxRating = 0.0
    
    // -------------------------------------------------------------------------
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Winner!!"
        navigationItem.backBarButtonItem?.tintColor = .white
        mapView.delegate = self
        if filterSelected != nil {
            selectWinnerFrom(data: YelpModel.data, minRating: filterSelected.minRating, maxRating: filterSelected.maxRating)
        } else if minRating != 0 {
            selectWinnerFrom(data: YelpModel.data, minRating: minRating, maxRating: maxRating)
        } else {
            selectWinnerFrom(data: YelpModel.data)
        }
        displayInformationFor(winner: foodletteWinner)
        displayPinLocationFor(winner: foodletteWinner)
        addInformationToHistoryFor(winner: foodletteWinner)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        filterSelected = nil
        minRating = 0.0
        maxRating = 0.0
    }
    
    // -------------------------------------------------------------------------
    // MARK: - UI Functionality
    
    func selectWinnerFrom(data: [Business], minRating: Double = 1.0, maxRating: Double = 5.0) {
        for _ in data.indices {
            let winnerSelected = Int.random(in: 0...YelpModel.data.count - 1)
            if data[winnerSelected].rating >= minRating && data[winnerSelected].rating <= maxRating {
                foodletteWinner = data[winnerSelected]
                break
            }
        }
    }
    
    func displayInformationFor(winner: Business) {
        winnerLabel.text = winner.name
        ratingImageView.image = winner.ratingImage
        reviewCountLabel.text = "\(String(describing: winner.reviewCount)) Reviews"
        let url = URL(string: winner.imageURL)
        let data = try? Data(contentsOf: url!)
        businessImageView.image = UIImage(data: data!)
    }
    
    func displayPinLocationFor(winner: Business) {
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = winner.coordinates.latitude
        annotation.coordinate.longitude = winner.coordinates.longitude
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 2500, longitudinalMeters: 2500)
        mapView.addAnnotation(annotation)
        mapView.setRegion(region, animated: true)
    }
    
    func addInformationToHistoryFor(winner: Business) {
        let history = History(context: dataController.viewContext)
        history.name = winner.name
        history.date = Date()
        history.rating = winner.rating
        history.reviewCount = "\(String(describing: winner.reviewCount)) Reviews"
        try? dataController.viewContext.save()
    }
}

// -----------------------------------------------------------------------------
// MARK: - Map View

extension WinnerViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.tintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
}
