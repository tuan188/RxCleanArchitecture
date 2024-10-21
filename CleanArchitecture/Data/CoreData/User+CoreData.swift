//
//  User+CoreData.swift
//  CleanArchitecture
//
//  Created by truong.anh.tuan on 21/10/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation

extension User: CoreDataMappable {
    init?(entity: CDUser) {
        guard let id = entity.id,
              let name = entity.name,
              let gender = Gender(rawValue: Int(entity.gender)),
              let birthday = entity.birthday else {
            return nil
        }
        
        self.init(id: id, name: name, gender: gender, birthday: birthday)
    }
    
    func map(to entity: CDUser) {
        entity.id = self.id
        entity.name = self.name
        entity.gender = Int64(self.gender.rawValue)
        entity.birthday = self.birthday
    }
}
