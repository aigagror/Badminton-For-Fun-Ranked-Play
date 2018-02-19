//
//  PlayerCollectionViewCell.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/18/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class PlayerCollectionViewCell: UICollectionViewCell {
    
    var player: Player!
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var id: UILabel!
    
    @IBOutlet weak var wins: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var level: UILabel!
    
}
