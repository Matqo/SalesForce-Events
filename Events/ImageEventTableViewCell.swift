//
//  ImageEventTableViewCell.swift
//  Events
//
//  Created by Martin Futas on 14/04/2017.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit

class ImageEventTableViewCell: UITableViewCell {

	@IBOutlet var eventImage: UIImageView!
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
