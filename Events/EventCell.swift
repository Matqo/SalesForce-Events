//
//  EventCell.swift
//  Events
//
//  Created by Martin Futas on 27/02/2017.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var createdBy: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
