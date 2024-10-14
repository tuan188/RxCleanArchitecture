//
//  Storage.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 10/25/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import Foundation

@propertyWrapper
struct Storage<T: Codable> {
    struct Wrapper<U>: Codable where U: Codable {
        let wrapped: U
    }
    
    private let key: String
    private let defaultValue: T
    
    init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T {
        get {
            guard let data = UserDefaults.standard.object(forKey: key) as? Data
            else { return defaultValue }
            let value = try? JSONDecoder().decode(Wrapper<T>.self, from: data)
            return value?.wrapped ?? defaultValue
        }
        set {
            do {
                let data = try JSONEncoder().encode(Wrapper(wrapped: newValue))
                UserDefaults.standard.set(data, forKey: key)
            } catch {
                print(error)
            }
        }
    }
}
