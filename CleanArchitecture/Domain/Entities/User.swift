//
//  User.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 1/8/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import Foundation
import Then

enum Gender: Int {
    case unknown = 0
    case male = 1
    case female = 2
    
    var name: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        default:
            return "Unknown"
        }
    }
}

struct User {
    var id = UUID().uuidString
    var name = ""
    var gender = Gender.unknown
    var birthday = Date()
}

extension User: Then { }
