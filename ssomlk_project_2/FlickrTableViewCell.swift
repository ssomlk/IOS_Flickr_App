//
//  FlickrTableViewCell.swift
//  ssomlk_project_2
//
//  Created by Wijekoon Mudiyanselage Shanka Primal Somasiri on 14/11/17.
//  Copyright © 2017 Wijekoon Mudiyanselage Shanka Primal Somasiri. All rights reserved.
//

import UIKit

class FlickrTableViewCell: UITableViewCell {

    
    @IBOutlet weak var imgFlickr: UIImageView!
    @IBOutlet weak var txtTitleFlickr: UILabel!
    @IBOutlet weak var txtDescriptionFlickr: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.imgFlickr.layer.cornerRadius = 5.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
