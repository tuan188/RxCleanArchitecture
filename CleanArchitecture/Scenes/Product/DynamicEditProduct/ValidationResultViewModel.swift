//
//  ValidationResultViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 9/11/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import Dto
import ValidatedPropertyKit
import UIKit

struct ValidationResultViewModel {
    let validationResult: ValidationResult
    
    var backgroundColor: UIColor {
        switch validationResult {
        case .success:
            return ColorCompatibility.systemBackground
        case .failure:
            return UIColor.yellow.withAlphaComponent(0.2)
        }
    }
    
    var text: String {
        switch validationResult {
        case .success:
            return " "
        case .failure(let error):
            return error.description
        }
    }
}
