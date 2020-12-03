//
//  ConcertViewController.swift
//  CONCERTS-19
//
//  Created by Jennifer Joseph on 12/2/20.
//

import UIKit

class ConcertViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    //var temp = ["Jennifer", "Margaret", "Joseph"]
    var concerts : Concerts!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        concerts = Concerts()
        
        // if you have a tableView, you will want this code too. the .isHidden will hide the tableView data so that it cannot be seen by anyone who has not logged in. (security feature)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        concerts.loadData {
            self.tableView.reloadData()
        }
    }
    
    // when the user selectes a table view cell, the data of that cell is passed over to concert view controller so it can be updated and saved by the user
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowConcert" {
            let destination = segue.destination as! ConcertDetailTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.concert = concerts.concertArray[selectedIndexPath.row]
        } // typically we would have a "AddConcert" else block but do not need that with Snapshot listener because it will handle when docs are added
    }
}

extension ConcertViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return concerts.concertArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = concerts.concertArray[indexPath.row].artist
        return cell
    }
}
