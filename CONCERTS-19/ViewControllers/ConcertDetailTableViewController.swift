//
//  ConcertDetailTableViewController.swift
//  CONCERTS-19
//
//  Created by Jennifer Joseph on 12/4/20.
//

import UIKit
import GooglePlaces // needed for Autocomplete to get places
import MapKit  //needed for map view to display location
import Firebase

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM d, yyyy, h:mm a"
    return dateFormatter
}()

class ConcertDetailTableViewController: UITableViewController {

    @IBOutlet weak var leftBarButton: UIBarButtonItem!
    @IBOutlet weak var saveBarButton: UIBarButtonItem!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var artistTextField: UITextField!
    @IBOutlet weak var ticketPriceTextField: UITextField!
    @IBOutlet weak var ticketLinkTextField: UITextField!
    @IBOutlet weak var venueTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var inPersonButton: UIButton!
    @IBOutlet weak var remoteButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var remoteLabel: UILabel!
    
    var concert : Concert!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // hide keyboard if we tap outside of field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if concert == nil {
            concert = Concert()
        }
        
        updateUserInterface()
    }
    
    func updateUserInterface() {
        artistTextField.text = concert.artist
        ticketPriceTextField.text = concert.ticketPrice
        ticketLinkTextField.text = concert.ticketLink
        datePicker.date = concert.date
        dateTextField.text = dateFormatter.string(from: concert.date)
        venueTextField.text = concert.venue
        //updateButtonImages(remote: concert.remote)
        inPersonButton.imageView?.image = UIImage(named: "People")
        remoteButton.imageView?.image = UIImage(named: "Computer")
        updateMap()
        
        // check if user that is logged in is user that posted this concert
        if concert.documentID == "" {
            print("new concert")
        } else {
            if concert.postingUserID == Auth.auth().currentUser?.uid {
                // change save to update
                saveBarButton.title = "Update"
                updateButtonImages(remote: concert.remote)
            } else {    // concert listed by diff user
                saveBarButton.hide()
                remoteLabel.text = "How You Can Attend:"
                leftBarButton.title = "Back"
                remoteButton.isEnabled = false
                inPersonButton.isEnabled = false
                updateButtonImages(remote: concert.remote)
                artistTextField.isEnabled = false
                venueTextField.isEnabled = false
                dateTextField.isEnabled = false
                datePicker.isHidden = true
                ticketLinkTextField.isEnabled = false
                ticketPriceTextField.isEnabled = false
            }
        }
    }
    
    func updateFromUserInterface() {
        concert.artist = artistTextField.text!
        concert.date = datePicker.date
        concert.venue = venueTextField.text!
        concert.ticketPrice = ticketPriceTextField.text!
        concert.ticketLink = ticketLinkTextField.text!
    }
    
    func updateButtonImages(remote: Bool) {
        concert.remote = remote
        if remote {
            inPersonButton.imageView?.image = UIImage(named: "FadedPeople")
            remoteButton.imageView?.image = UIImage(named: "Computer")
        } else {
            inPersonButton.imageView?.image = UIImage(named: "People")
            remoteButton.imageView?.image = UIImage(named: "FadedComputer")
        }
        tableView.beginUpdates()
        tableView.endUpdates()
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
        //self.leaveViewController()
        concert.saveData { success in
            if success {
//                if self.concert.remote == false {
//                    self.oneButtonAlert(title: "COVID ADVISORY", message: "Practice social distancing and wear a mask.") {
//                        self.leaveViewController()
//                    }
//                } else {
//                    self.leaveViewController()
//                }
                self.leaveViewController()
            } else {
                print("*** ERROR: Couldn't leave this view controller because data wasn't saved.")
            }
        }
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        dateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func inPersonButtonPressed(_ sender: UIButton) {
        updateButtonImages(remote: false)
        // need to do something here that shows user which button they hit
    }
    
    @IBAction func remoteButtonPressed(_ sender: UIButton) {
        updateButtonImages(remote: true)
        // need to do something here that shows user which button they hit
    }
    
    @IBAction func venueTextFieldPressed(_ sender: UITextField) {
        let autocompleteController = GMSAutocompleteViewController()    // create Google AutoComplete View Controller
        autocompleteController.delegate = self  // set delegate
        present(autocompleteController, animated: true, completion: nil) // present it so that when user presses Find Venue, the Google AutoComplete dialogue pops up
    }
    
}


extension ConcertDetailTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case IndexPath(row: 1, section: 1):
            return (concert.documentID == "" || concert.postingUserID == Auth.auth().currentUser?.uid) ? 52 : 0
        case IndexPath(row: 0, section: 5):
            return concert.remote ? 0 : 250
        case IndexPath(row: 0, section: 4):
            return 160
        default:
            return 44
        }
    }
}



// from https://developers.google.com/places/ios-sdk/autocomplete?authuser=2

extension ConcertDetailTableViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        // commented print statements are given on the website
        //        print("Place name: \(place.name)")
        //        print("Place ID: \(place.placeID)")
        //        print("Place attributions: \(place.attributions)")
        
        // for our app, we want to take whatever is searched for and returned by Google as place.name and put it into our venue property of our Concert object
        // place is returned by Google and it has a .name property (this is an optional)
        
        updateFromUserInterface() // call this first to get whatever the user has typed in text field of detail static table view
        concert.venue = place.name ?? "Unknown Venue" // then update from places
        concert.coordinate = place.coordinate // save the place coordiate containing lat/lon of place to the place coord
        updateUserInterface()  // then call this so that the concert object has all of the latest values
        //updateMap() // then call this last to also update the mapview
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
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
