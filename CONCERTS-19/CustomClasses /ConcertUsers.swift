//
//  ConcertUsers.swift
//  CONCERTS-19
//
//  Created by Jennifer Joseph on 12/2/20.
//

import Foundation
import Firebase

// all of our plural-named classes have arrays inside of them of the singlular-named classes to be able to load in a bunch of elements of a particular type
//

class ConcertUsers {
    var userArray : [ConcertUser] = []
    var db : Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR when adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.userArray = [] // clean out existing userArray since new data will load
            // there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                let concertUser = ConcertUser(dictionary: document.data())
                concertUser.documentID = document.documentID
                self.userArray.append(concertUser)
            }
            completed()
        }
    }
}
