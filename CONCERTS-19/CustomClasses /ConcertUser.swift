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
    var documentID : String
    
    // create dictionary - computed property to convert class properties to a dictionary so that we can write them out to CloudFireStore
    // ANY CLOUD FIRESTORE CLASS NEEDS DICTIONARY
    
    var dictionary : [String: Any] {
        return ["email": email]
    }
    
    // base initializer
    init(email: String, documentID: String) {
        self.email = email
        self.documentID = documentID
    }
    
    // convenience initializer # 1
    // initializer passes in a single parameter, a user object (firebase type User)
    // doing this because it is the same data structure that gives us the current user which tells us all the email, userSince, etc info
    // don't forget that these MIGHT BE NIL -- use nil coalescing
    
    convenience init(user: User) {
        let email = user.email ?? ""
        self.init(email: email, documentID: user.uid)  // note: document ID set to user.uid
    }
    
    // convenience initializer # 2
    convenience init(dictionary: [String: Any]) {
        let email = dictionary["email"] as! String? ?? ""
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
