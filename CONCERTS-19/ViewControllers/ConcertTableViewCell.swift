//
//  ConcertTableViewCell.swift
//  CONCERTS-19
//
//  Created by Jennifer Joseph on 12/3/20.
//

import UIKit

class ConcertTableViewCell: UITableViewCell {

    @IBOutlet weak var concertTypeImageView: UIImageView!
    @IBOutlet weak var artistLabel: UILabel!
    
    var concert: Concert! {
        didSet {
            // update user interface
            var image = concert.remote == true ? "desktopcomputer" : "person.3.fill"
            concertTypeImageView.image = UIImage(named: "\(image)")
            concertTypeImageView.image?.withTintColor(.white)
            artistLabel.text = concert.artist
        }
    }
}
