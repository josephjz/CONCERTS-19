//
//  Concerts.swift
//  CONCERTS-19
//
//  Created by Jennifer Joseph on 12/2/20.
//

import Foundation
import Firebase

class Concerts {
    var concertArray : [Concert] = []
    var db : Firestore!
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping () -> ()) {
        db.collection("concerts").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("ERROR when adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.concertArray = [] // clean out existing concertArray since new data will load
            // there are querySnapshot!.documents.count documents in the snapshot
            for document in querySnapshot!.documents {
                let concert = Concert(dictionary: document.data())
                concert.documentID = document.documentID
                self.concertArray.append(concert)
            }
            completed()
        }
    }
}
        
   
