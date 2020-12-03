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
            let destination = segue.destination as! ConcertDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.concert = concerts.concertArray[selectedIndexPath.row]
        } // typically we would have a "AddConcert" else block but do not need that with Snapshot listener because it will handle when docs are added
    }
    
//    // LEGGO (things that need to be changed (like array name) will be underlined as errors)
//    @IBAction func unwindFromDetail(segue: UIStoryboardSegue) {
//        let source = segue.source as! ConcertDetailViewController
//        if let selectedIndexPath = tableView.indexPathForSelectedRow {
//            concerts.concertArray[selectedIndexPath.row].artist = source.concert.artist
//            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
//        } else { // if selected row is nil (clicked plus button)
//            let newIndexPath = IndexPath(row: concerts.concertArray.count, section: 0)
//            concerts.concertArray.append(source.concert)
//            tableView.insertRows(at: [newIndexPath], with: .bottom)
//            tableView.scrollToRow(at: newIndexPath, at: .bottom, animated: true)
//        }
//    }
}

extension ConcertViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return concerts.concertArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ConcertTableViewCell
        cell.concert = concerts.concertArray[indexPath.row]
        //cell.textLabel?.text = concerts.concertArray[indexPath.row].artist
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
