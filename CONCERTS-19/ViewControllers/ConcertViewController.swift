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
        navigationController?.setToolbarHidden(false, animated: true)
        concerts.loadData {
            self.tableView.reloadData()
            for delete in self.concerts.concertArray {  // this for loop will delete the concerts that have already happened 
                if delete.date < Date() {
                    delete.deleteData(concert: delete) { (success) in
                        if success {
                            print("success")
                        } else {
                            print("😡 Delete unsuccessful")
                        }
                    }
                }
            }
            self.concerts.concertArray.sort(by: {$0.date < $1.date}) // show the concerts in the table view by soonest to furthest away
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
    
    @IBAction func infoButtonPressed(_ sender: UIBarButtonItem) {
        present(InfoViewController(), animated: true, completion: nil)
    }
    
    
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
