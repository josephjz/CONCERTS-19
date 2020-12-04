//
//  InPersonConcertDetailTableViewController.swift
//  CONCERTS-19
//
//  Created by Jennifer Joseph on 12/2/20.
//

import UIKit
import GooglePlaces // needed for Autocomplete to get places
import MapKit  //needed for map view to display location

class ConcertDetailViewController: UITableViewController {
    
    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var ticketPriceTextField: UITextField!
    @IBOutlet weak var ticketLinkTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var inPersonButton: UIButton!
    @IBOutlet weak var remoteButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    var concert : Concert!
    
    //let datePicker = UIDatePicker()
    
    //    private let dateFormatter: DateFormatter = {
    //        let dateFormatter = DateFormatter()
    //        dateFormatter.dateFormat = "MMM d, yyyy, h:mm a"
    //        return dateFormatter
    //    }()
    
    let regionDistance : CLLocationDistance = 20000 // declares a value (20000 m) to use for the requested 20km map area
    //CLLocationDegrees = 750.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create the region, centered at the University's coordinates, and spanning horizontally and vertically by regionDistance
        //let region = MKCoordinateRegion(center: concert.coordinate, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        //mapView.setRegion(region, animated: true)
        //let datePicker = UIDatePicker() // instantiating instance of Date Picker
        //datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(ConcertDetailViewController.showDatePicker), for: .valueChanged)
        dateTextField.inputView = datePicker
        
        // hide keyboard if we tap outside of field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if concert == nil {
            concert = Concert()
        }
        
        updateUserInterface()
        
    }
    
    //@objc func dateChanged(datePicker: UIDatePicker) {
    // concert.date = datePicker.date
    //dateTextField.text = "\(dateFormatter.string(from: concert.date))"
    //view.endEditing(true)   // forces firstResponder (which is the datePicker) to dismiss itself
    //}
    
    func updateUserInterface() {
        artistTextField.text = concert.artist
        ticketPriceTextField.text = concert.ticketPrice
        ticketLinkTextField.text = concert.ticketLink
        datePicker.date = concert.date
        // images handled in buttons
        updateMap()
    }
    
    func updateFromUserInterface() {
        concert.artist = artistTextField.text!
        concert.date = datePicker.date
        // images handled in buttons
        concert.ticketPrice = ticketPriceTextField.text!
        concert.ticketLink = ticketLinkTextField.text!
    }
    
    @objc func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .dateAndTime
        
        //ToolBar
        let toolbar = UIToolbar();
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))//1
        datePicker.datePickerMode = .dateAndTime
//        datePicker.addTarget(self, action: #selector(ConcertDetailViewController.showDatePicker), for: .valueChanged)
//        dateTextField.inputView = datePicker

        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 100.0)) //4
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        
        dateTextField.inputAccessoryView = toolbar
        dateTextField.inputView = datePicker
    }
    
    @objc func donedatePicker(){
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy, h:mm a"
        dateTextField.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    
    func updateMap() {
        mapView.removeAnnotations(mapView.annotations)      // removes any old annotations
        mapView.addAnnotation(concert)     // plots the new one for the current concert
        mapView.setCenter(concert.coordinate, animated: true)
    }
    
    // call from both IBActions
    func leaveViewController() {
        // when this is true, we know it was presented by a Navigation Controller
        // which means it must have bene presented modally
        // which means we need to use a dismiss instead of a pop
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func leftBarButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func saveBarButtonPressed(_ sender: UIBarButtonItem) {
        // When reusing this code, the only changes required may be to concert.saveData (you'll likley have a different object, and it is possible that you might pass in parameters if you're saving to a longer document reference path
        updateFromUserInterface()
        concert.saveData { success in
            if success {
                self.leaveViewController()
            } else {
                print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
            }
        }
        
    }
    
    @IBAction func inPersonButtonPressed(_ sender: UIButton) {
        concert.remote = false
        remoteButton.alpha = 0.5
        inPersonButton.alpha = 1.0
        // need to do something here that shows user which button they hit
    }
    
    @IBAction func remoteButtonPressed(_ sender: UIButton) {
        concert.remote = true
        remoteButton.alpha = 1.0
        inPersonButton.alpha = 0.5
        // need to do something here that shows user which button they hit
    }
}


//extension ConcertDetailViewController {
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        switch indexPath {
//        case IndexPath(row: 5, section: 0):
//            return concert.remote ? mapView.frame.height : 0
//           // trying to simulate hiding the mapView
//        default:
//            return 44
//        }
//    }
//}



// from https://developers.google.com/places/ios-sdk/autocomplete?authuser=2

extension ConcertDetailViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        // commented print statements are given on the website
        //        print("Place name: \(place.name)")
        //        print("Place ID: \(place.placeID)")
        //        print("Place attributions: \(place.attributions)")
        
        // for our app, we want to take whatever is searched for and returned by Google as place.name and put it into our university property of our Team object
        // place is returned by GOogle and it has a .name property (this is an optional)
        
        updateFromUserInterface() // call this first to get whatever the user has typed in text field of detail static table view
        concert.coordinate = place.coordinate // save the place coordiate containing lat/lon of place to the place coord
        updateUserInterface()  // then call this so that the team object has all of the latest values
        updateMap() // then call this last to also update the mapview
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
