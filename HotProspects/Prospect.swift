//
//  Prospect.swift
//  HotProspects
//
//  Created by Gamıd Khalıdov on 28.06.2024.
//

import Foundation
import SwiftData

@Model
class Prospect {
    var name: String
    var emailAddress: String
    var isContacted: Bool
    var date: Date
    
    init(name: String, emailAddress: String, isContacted: Bool) {
        self.name = name
        self.emailAddress = emailAddress
        self.isContacted = isContacted
        self.date = Date.now
    }
    
    static func currentPredicate() -> Predicate<Prospect> {
            let currentDate = Date.now

            return #Predicate<Prospect> { festival in
                festival.date > currentDate
            }
        }

    static func pastPredicate() -> Predicate<Prospect> {
        let currentDate = Date.now

        return #Predicate<Prospect> { festival in
            festival.date < currentDate
        }
    }
    
}
