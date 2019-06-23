//
//  FoodletteFilterCell.swift
//  Foodlette
//
//  Created by Justin Kampen on 5/24/19.
//  Copyright © 2019 Justin Kampen. All rights reserved.
//

import UIKit

class FoodletteFilterCell: UICollectionViewCell {
    
    // -------------------------------------------------------------------------
    // MARK: - Outlets
    
    @IBOutlet weak var filterNameLabel: UILabel!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // -------------------------------------------------------------------------
    // MARK: - Selected Cell Display
    
    var isEditing: Bool = false {
        didSet {
            selectionImageView.isHidden = !isEditing
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isEditing {
                selectionImageView.image = isSelected ? UIImage(named: "Checked") : UIImage(named: "Unchecked")
            }
        }
    }
}
