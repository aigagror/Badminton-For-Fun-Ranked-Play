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
        if nickname == nil && firstName == nil && lastName == nil {
            guard let id = id else {
                fatalError()
            }
            return id
        }
        return nickname ?? "\(firstName ?? "") \(lastName ?? "")"
    }
}
