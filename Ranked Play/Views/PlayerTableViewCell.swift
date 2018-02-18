//
//  PlayerTableViewCell.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/8/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {

    // MARK: Properties
    
    var player: Player!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var wins: UILabel!
    @IBOutlet weak var level: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
