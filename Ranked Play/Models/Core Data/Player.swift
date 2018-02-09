//
//  Player.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/9/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import Foundation

extension Player {
    var name: String {
        return nickname ?? "\(firstName ?? "") \(lastName ?? "")"
    }
}
