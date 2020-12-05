//
//  ConcertUser.swift
//  CONCERTS-19
//
//  Created by Jennifer Joseph on 12/2/20.
//
import Foundation
import Firebase

class ConcertUser {
    var email : String
    //var displayName : String
    //var photoURL : String
    //var userSince : Date
    var documentID : String
    
    // create dictionary - computed property to convert class properties to a dictionary so that we can write them out to CloudFireStore
    // ANY CLOUD FIRESTORE CLASS NEEDS DICTIONARY
    
    var dictionary : [String: Any] {
        // have to convert Date to TimeInterval becuase can't save Apple Date to Firestore
        //let timeIntervalDate = userSince.timeIntervalSince1970
        
        // put all key-valkue pairs of dictionary into this return line
        // key string is same as variable names
        //return ["email": email, "displayName": displayName, "photoURL" : photoURL, "userSince": timeIntervalDate]
        return ["email": email]

    }
    
    // base initializer
//    init(email: String, displayName: String, photoURL: String, userSince: Date, documentID: String) {
//        self.email = email
//        //self.displayName = displayName
//        //self.photoURL = photoURL
//        //self.userSince = userSince
//        self.documentID = documentID
//    }
    
    init(email: String, documentID: String) {
        self.email = email
        //self.displayName = displayName
        //self.photoURL = photoURL
        //self.userSince = userSince
        self.documentID = documentID
    }
    
    
    
    // convenience initializer # 1
    // initializer passes in a single parameter, a user object (firebase type User)
    // doing this because it is the same data structure that gives us the current user which tells us all the email, userSince, etc info
    // don't forget that these MIGHT BE NIL -- use nil coalescing
    
    convenience init(user: User) {
        let email = user.email ?? ""
        //let displayName = user.displayName ?? ""
        //let photoURL =  user.photoURL != nil ? "\(user.photoURL!)" : ""   // note here: photoURL will give us a URL but we want a string so we have to convert it w a ternary operator
        //self.init(email: email, displayName: displayName, photoURL: photoURL, userSince: Date(), documentID: user.uid)  // note: set userSince to Date() to set it to current date
        self.init(email: email, documentID: user.uid)  // note: document ID set to user.uid
    }
    
    // convenience initializer # 2
    // will take in [String: Any] type key-value pairs that come back from the dictionary read in from Firestore
    // convert into SnackUser object
    /// recall for dictionaries : pass in keys to Dict that are strings that are paired up with values, if the key is correct we should match it to the value, otherwise we will get nil (nil coalescing)
    
    convenience init(dictionary: [String: Any]) {
        let email = dictionary["email"] as! String? ?? ""
        //let displayName = dictionary["displayName"] as! String? ?? ""
        //let photoURL = dictionary["photoURL"] as! String? ?? ""
        //let timeIntervalDate = dictionary["userSince"] as! TimeInterval? ?? TimeInterval()
        //let userSince = Date(timeIntervalSince1970: timeIntervalDate)
        //self.init(email: email, displayName: displayName, photoURL: photoURL, userSince: userSince, documentID: "")    // remember that we don't get the documentID from dictionary
        self.init(email: email, documentID: "")    // remember that we don't get the documentID from dictionary

    }
    
    func saveIfNewUser(completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(documentID)   // create document reference to new users collection
        
        userRef.getDocument { (document, error) in
            guard error == nil else {
                print("ERROR: could not access document for user \(self.documentID)")
                return completion(false)
            }
            guard document?.exists == false else {
                print("Hey! The document for user \(self.documentID) already exists! No reason to re-create it.")
                return completion(true)
            }
            
            // create the new document; remember that we make the dictionary so we can save it out to Cloud Firestore
            let dataToSave: [String: Any] = self.dictionary
            db.collection("users").document(self.documentID).setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR: \(error!.localizedDescription), could not save data for \(self.documentID)")
                    return completion(false)
                }
                return completion(true)
            }
        }
    }
}
