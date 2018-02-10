//
//  MatchTableViewCell.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/9/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell {

    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var nameOne: UILabel!
    @IBOutlet weak var scoreOne: UILabel!
    @IBOutlet weak var nameTwo: UILabel!
    @IBOutlet weak var scoreTwo: UILabel!
    
    @IBOutlet weak var finishedLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
