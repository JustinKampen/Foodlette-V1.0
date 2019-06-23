//
//  ViewController+Extras.swift
//  Foodlette
//
//  Created by Justin Kampen on 5/24/19.
//  Copyright © 2019 Justin Kampen. All rights reserved.
//

import UIKit

// -----------------------------------------------------------------------------
// MARK: - Status Bar Styling

extension UINavigationController {
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UIColor {
    static let foodletteBlue = UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1.0)
}

// -----------------------------------------------------------------------------
// MARK: - View Controller Extensions

extension UIViewController {
    
    // -------------------------------------------------------------------------
    // MARK: - Display Alert Message
    // Displays error message/alert to user
    
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // -------------------------------------------------------------------------
    // MARK: - Collection View Styling
    // Adds card-like appearance to cells
    
    func cellStyling(_ cell: UICollectionViewCell) {
        cell.contentView.layer.cornerRadius = 10.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = true
        cell.layer.shadowColor = UIColor.lightGray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.layer.shadowRadius = 3.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
    }
    
    func imageViewSyling(_ imageView: UIImageView) {
        imageView.layer.cornerRadius = 10.0
        imageView.layer.borderWidth = 1.0
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.masksToBounds = true
    }
    
    func roundStyling(_ view: UIView) {
        view.layer.cornerRadius = 5.0
        view.layer.masksToBounds = true
    }
}


