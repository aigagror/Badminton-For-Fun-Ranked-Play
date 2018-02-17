//
//  MatchCollectionViewCell.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/16/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class MatchCollectionViewCell: UICollectionViewCell {
    var match: Match!
    
    @IBOutlet weak var startDate: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var inProgressIndicator: UILabel!
    
    @IBOutlet weak var teamOneScore: UILabel!
    @IBOutlet weak var teamTwoScore: UILabel!
    @IBOutlet weak var playerOneName: UILabel!
    @IBOutlet weak var playerTwoName: UILabel!
    @IBOutlet weak var playerThreeName: UILabel!
    @IBOutlet weak var playerFourName: UILabel!
    
    override func draw(_ rect: CGRect) {
        clipsToBounds = false
        layer.masksToBounds = false
    }
}
