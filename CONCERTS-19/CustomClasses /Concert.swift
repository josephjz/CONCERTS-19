//
//  Concert.swift
//  CONCERTS-19
//
//  Created by Jennifer Joseph on 12/2/20.
//

import Foundation
import CoreLocation
import Firebase // for saveData method
import MapKit   // for MapView pin

class Concert: NSObject, MKAnnotation {
    
    var artist : String
    var date : Date
    var ticketPrice : String
    var remote : Bool                       // FIGURE THIS OUT
    var ticketLink : String
    var coordinate : CLLocationCoordinate2D     // don't forget IMPORT STATEMENT
    //var attending :
    var postingUserID : String
    var documentID : String
    
    // have to use a computed property for coordinate, latitude, and longitude
    var latitude : CLLocationDegrees {
        return coordinate.latitude
    }
    
    var longitude : CLLocationDegrees {
        return coordinate.longitude
    }
    
    // to display title in mapview pin
    var title: String? {
        return "\(artist) Concert"
    }
    
    // computed property of Concert Class called dictionary
    // it is a computed property because it does not hold values, but the values are computed using other properties! (makes sense)
    // this creates a dictionary of all the properties in our class
    // we do this because Cloud Firestore saves data out as a dictionary
    // so whenever we refer to an object of type Concert and its .dictionary property, we will be creating a dictionary that we can save to the cloud
    
    var dictionary : [String: Any] {
        
        // need to figure out date part
        let timeIntervalDate = date.timeIntervalSince1970
        
        return ["artist": artist, "date": timeIntervalDate, "ticketPrice": ticketPrice, "remote": remote, "ticketLink": ticketLink, "latitude": latitude, "longitude": longitude, "postingUserID": postingUserID, "documentID": documentID]
    }
    
    init(artist: String, date: Date, ticketPrice: String, remote: Bool, ticketLink: String, coordinate: CLLocationCoordinate2D, postingUserID: String, documentID: String) {
        
        self.artist = artist
        self.date = date
        self.ticketPrice = ticketPrice
        self.remote = remote
        self.ticketLink = ticketLink
        self.coordinate = coordinate
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    
    // Concert convenience initializer that takes a dictionary as input parameter
    // data from cloud firestore is read back in to our app via a dictionary, so this convenience initializer takes a dicitonary that we get back from cloud firestore and will give us back an individual Concert object
    
    
    convenience init(dictionary: [String: Any]) {
        
        let artist = dictionary["artist"] as! String? ?? ""
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()           // note that here (when coming back from firestore to code we convert to type Date
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let ticketPrice = dictionary["ticketPrice"] as! String? ?? ""
        let remote = dictionary["remote"] as! Bool? ?? true
        let ticketLink = dictionary["ticketLink"] as! String? ?? ""
        let latitude = dictionary["latitude"] as! CLLocationDegrees? ?? 0.0
        let longitude = dictionary["longitude"] as! CLLocationDegrees? ?? 0.0
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        
        self.init(artist: artist, date: date, ticketPrice: ticketPrice, remote: remote, ticketLink: ticketLink, coordinate: coordinate, postingUserID: postingUserID, documentID: "")
    }
    
    
    // use the convenience initializer in our code like this
    // let concert = Concert()
    // this creates a new object of type Team
    
    convenience override init() {   // before having the map, we had just convenience init(), accept fix suggested to add override here
        self.init(artist: "", date: Date(), ticketPrice: "", remote: true, ticketLink: "", coordinate: CLLocationCoordinate2D(), postingUserID: "", documentID: "")
    }
    
    // NOTE: If you keep the same programming conventions (e.g. a calculated property .dictionary that converts class properties to String: Any pairs, the name of the document stored in the class as .documentID) then the only thing you'll need to change is the document path (i.e. the lines containing "concerts" below.
    
    // save one team at a time
    func saveData(completion: @escaping (Bool) -> ())  {
        let db = Firestore.firestore()
        // Grab the user ID
        guard let postingUserID = (Auth.auth().currentUser?.uid) else {
            print("*** ERROR: Could not save data because we don't have a valid postingUserID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        // Create the dictionary representing data we want to save
        let dataToSave: [String: Any] = self.dictionary
        // if we HAVE saved a record, we'll have an ID
        if self.documentID != "" {
            let ref = db.collection("concerts").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if let error = error {
                    print("ERROR: updating document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked!
                    completion(true)
                }
            }
        } else { // Otherwise create a new document via .addDocument
            var ref: DocumentReference? = nil // Firestore will creat a new ID for us
            ref = db.collection("concerts").addDocument(data: dataToSave) { (error) in
                if let error = error {
                    print("ERROR: adding document \(error.localizedDescription)")
                    completion(false)
                } else { // It worked! Save the documentID in Spot’s documentID property
                    self.documentID = ref!.documentID
                    completion(true)
                }
            }
        }
    }
}
