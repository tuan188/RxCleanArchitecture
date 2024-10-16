//
//  ValidationError.swift
//  CleanArchitecture
//
//  Created by truong.anh.tuan on 15/10/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation

public struct ValidationError: LocalizedError {
    public var errorDescription: String? { description }
    public let description: String
    
    public init(description: String) {
        self.description = description
    }
    
    public init(descriptions: [String]) {
        self.description = descriptions.joined(separator: "\n")
    }
}
