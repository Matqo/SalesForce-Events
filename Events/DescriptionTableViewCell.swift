//
//  DescriptionTableViewCell.swift
//  Events
//
//  Created by Martin Futas on 16/04/2017.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {
	@IBOutlet var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
