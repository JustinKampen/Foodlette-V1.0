//
//  AddFilterViewController.swift
//  Foodlette
//
//  Created by Justin Kampen on 5/24/19.
//  Copyright © 2019 Justin Kampen. All rights reserved.
//

import UIKit
import CoreData

class AddFilterViewController: UIViewController, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate {
    
    // -------------------------------------------------------------------------
    // MARK: - Outlets and Properties
    
    @IBOutlet weak var filterNameTextField: UITextField!
    @IBOutlet weak var filterCategoryTextField: UITextField!
    @IBOutlet weak var minRatingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var maxRatingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var albumsButton: UIBarButtonItem!
    
    let foodletteViewController = FoodletteViewController()
    var dataController: DataController!
    var minRating = 1.0
    var maxRating = 5.0
    
    // -------------------------------------------------------------------------
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Create New Filter"
        navigationItem.backBarButtonItem?.tintColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(handleAddFilter))
        filterNameTextField.delegate = self
        filterCategoryTextField.delegate = self
        imageViewSyling(filterImageView)
    }

    // -------------------------------------------------------------------------
    // MARK: - ImagePicker Functionality
    
    func pickImageFrom(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.navigationBar.isTranslucent = false
        imagePicker.navigationBar.barTintColor = .foodletteBlue
        imagePicker.navigationBar.tintColor = .white
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromCamera(_ sender: Any) {
        pickImageFrom(sourceType: .camera)
    }
    
    @IBAction func pickImageFromAlbums(_ sender: Any) {
        pickImageFrom(sourceType: .photoLibrary)
    }
    
    // -------------------------------------------------------------------------
    // MARK: - UI Functionality
    
    @objc func handleAddFilter() {
        if filterNameTextField.text == "" {
            alert(message: "Enter a name for your filter")
        } else if minRating > maxRating {
            alert(message: "The minimum rating cannot exceed the maximum rating")
        } else if filterImageView.image == nil {
            alert(message: "Select an image for your filter")
        } else {
            saveFilter()
            foodletteViewController.dataController = dataController
            navigationController?.popViewController(animated: true)
        }
    }
    
    func saveFilter() {
        let filter = Filter(context: dataController.viewContext)
        filter.name = filterNameTextField.text
        let category = filterCategoryTextField.text?.replacingOccurrences(of: " ", with: "")
        filter.category = category
        filter.minRating = minRating
        filter.maxRating = maxRating
        if let filterImage = filterImageView.image {
            let imageData = filterImage.jpegData(compressionQuality: 0.8)
            filter.image = imageData
        }
        try? dataController.viewContext.save()
    }
    
    @IBAction func updateMinRatingValue(_ sender: Any) {
        minRating = Double(minRatingSegmentedControl.selectedSegmentIndex) + 1.0
    }

    @IBAction func updateMaxRatingValue(_ sender: Any) {
        maxRating = Double(maxRatingSegmentedControl.selectedSegmentIndex) + 1.0
    }
}

extension AddFilterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension AddFilterViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            filterImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

