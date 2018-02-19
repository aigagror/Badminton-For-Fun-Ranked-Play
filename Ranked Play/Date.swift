//
//  Date.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/16/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import Foundation

extension Date {
    static let numberOfSecondsInADay: TimeInterval = 60 * 60 * 24
    
    static func dateSince(numberOfDaysHavePassed n: Int) -> Date {
        let offset = Date().addingTimeInterval(numberOfSecondsInADay * TimeInterval(n))
        return offset
    }
}
