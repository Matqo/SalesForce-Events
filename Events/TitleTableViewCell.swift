//
//  TitleTableViewCell.swift
//  Events
//
//  Created by Martin Futas on 15/04/2017.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit

class TitleTableViewCell: UITableViewCell {
	@IBOutlet var Title: UILabel!

	@IBOutlet var month: UILabel!
	@IBOutlet var dateDay: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
