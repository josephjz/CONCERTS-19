//
//  ConcertTypeViewController.swift
//  CONCERTS-19
//
//  Created by Jennifer Joseph on 12/2/20.
//

import UIKit

class ConcertTypeViewController: UIViewController {

    @IBOutlet weak var computerImageView: UIImageView!
    @IBOutlet weak var peopleImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // soften corners of image view

        computerImageView.backgroundColor = UIColor.white
        computerImageView.layer.cornerRadius = 8.0
        computerImageView.clipsToBounds = true
        
        peopleImageView.backgroundColor = UIColor.white
        peopleImageView.layer.cornerRadius = 8.0
        peopleImageView.clipsToBounds = true
    }
    
    @IBAction func computerImageTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "AddConcert", sender: nil)
    }
    
    @IBAction func peopleImageTapped(_ sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "AddConcert", sender: nil)
    }
}


