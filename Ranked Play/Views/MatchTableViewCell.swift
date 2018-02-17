//
//  MatchTableViewCell.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/9/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class MatchTableViewCell: UITableViewCell {

    var match: Match!
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var playerOneName: UILabel!
    @IBOutlet weak var teamOneScore: UILabel!
    @IBOutlet weak var playerTwoName: UILabel!
    @IBOutlet weak var teamTwoScore: UILabel!
    
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
