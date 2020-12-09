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
    
    func loadData(completed: @escaping () -> ())  {
        // the .addSnapshotListener method says whenever anything changes in "teams", run the code in the first {}, which will load in the new data with any changes
        db.collection("concerts").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("*** ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.concertArray = []     // empty out array or else you will get duplicates
            // there are querySnapshot!.documents.count documents in the teams snapshot
            for document in querySnapshot!.documents {      // the loop goes through all the documents (teams) returned by the querySnapshot. each document has data stored in a dictionary in document.data()
              // You'll have to be sure you've created an initializer in the singular class (Team, below) that acepts a dictionary.
                let concert = Concert(dictionary: document.data())
                concert.documentID = document.documentID
                self.concertArray.append(concert)
            }
            completed()
        }
    }
}


        
   
