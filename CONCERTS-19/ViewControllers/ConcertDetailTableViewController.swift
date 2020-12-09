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
    @IBOutlet weak var getTicketButton: UIButton!
    
    var concert : Concert!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide keyboard if we tap outside of field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        if concert == nil {
            saveBarButton.isEnabled = false
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
        inPersonButton.imageView?.image = UIImage(named: "People")
        remoteButton.imageView?.image = UIImage(named: "Computer")
        updateMap()
        
        // check if user that is logged in is user that posted this concert
        if concert.documentID == "" {
            print("new concert")
            dateTextField.text = ""
        } else {
            if concert.postingUserID == Auth.auth().currentUser?.uid {
                // change save to update
                saveBarButton.title = "Update"
                getTicketButton.isHidden = true
                updateButtonImages(remote: concert.remote)
            } else {    // concert listed by diff user
                saveBarButton.hide()
                remoteLabel.text = "How You Can Attend:"
                leftBarButton.title = "Back"
                remoteButton.isEnabled = false
                getTicketButton.isHidden = false
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
    
    func openLink() {
        var useThis = concert.ticketLink.lowercased()   // fix capitalization
        if useThis.starts(with: "www.") {
            useThis = "http://" + useThis
        } else if useThis.starts(with: "http://www.") {
            print("good to go ")
        } else {
            useThis = "http://www." + useThis
        }
        if useThis.contains(".com") {
            var url = URL(string: useThis)!
            UIApplication.shared.open(url)
        } else {
            UIApplication.shared.open((URL(string: "https://www.google.com")!))
            print("google")
        }
    }
    
    func disableSave() {
        if (dateFormatter.string(from: datePicker.date) == dateFormatter.string(from: Date())) || ticketLinkTextField.text == "" || artistTextField.text == "" || ticketPriceTextField.text == ""  {
            saveBarButton.isEnabled = false
        } else {
            saveBarButton.isEnabled = true
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
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        print("sender.date: \(dateFormatter.string(from: sender.date))")
        print("current date: \(dateFormatter.string(from: Date()))")
        disableSave()
        dateTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @IBAction func inPersonButtonPressed(_ sender: UIButton) {
        disableSave()
        updateButtonImages(remote: false)
    }
    
    @IBAction func remoteButtonPressed(_ sender: UIButton) {
        disableSave()
        updateButtonImages(remote: true)
    }
    
    @IBAction func ticketLinkPressed(_ sender: UITextField) {
        disableSave()
    }
    
    @IBAction func ticketPricePressed(_ sender: UITextField) {
        disableSave()
    }
    
    @IBAction func artistNamePressed(_ sender: UITextField) {
        disableSave()
    }
    
    @IBAction func venueTextFieldPressed(_ sender: UITextField) {
        //saveBarButton.isEnabled = venueTextField.text == "" ? false : true
        disableSave()
        let autocompleteController = GMSAutocompleteViewController()    // create Google AutoComplete View Controller
        autocompleteController.delegate = self  // set delegate
        present(autocompleteController, animated: true, completion: nil) // present it so that when user presses Find Venue, the Google AutoComplete dialogue pops up
        disableSave()

    }
    
    @IBAction func getTicketsPressed(_ sender: UIButton) {
        if !concert.remote {
            let alertController = UIAlertController(title: "COVID-19 Advisory", message: "Please mask up and practice social distancing if you attend this event.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
                self.openLink()
            })
            alertController.addAction(defaultAction)
            present(alertController, animated: true, completion: nil)
        } else {
            openLink()
        }
    }
    
}


extension ConcertDetailTableViewController {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case IndexPath(row: 1, section: 1): // if you are the lister, then u should see the data picker, otherwise hide it
            return (concert.documentID == "" || concert.postingUserID == Auth.auth().currentUser?.uid) ? 52 : 0
        case IndexPath(row: 0, section: 3): // if you are viewing someone elses concert, hide the ticket link
            return (concert.documentID == "" || concert.postingUserID == Auth.auth().currentUser?.uid) ? 44 : 0
        case IndexPath(row: 0, section: 4):
            return 160
        case IndexPath(row: 0, section: 5): // if the concert is remote, hide the venue map
            return concert.remote ? 0 : 250
        case IndexPath(row: 0, section: 6): // if the concert is new, hide the ticket button
            return concert.documentID == "" ? 0 : 44
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
