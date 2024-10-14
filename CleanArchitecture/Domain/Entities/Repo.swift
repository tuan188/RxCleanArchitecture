//
//  Repo.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/28/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import Then

struct Owner: Codable {
    var avatarURLString: String
    
    enum CodingKeys: String, CodingKey {
        case avatarURLString = "avatar_url"
    }
}

struct Repo: Codable {
    var id: Int
    var name: String
    var fullname: String
    var urlString: String
    var starCount: Int
    var folkCount: Int
    var owner: Owner

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullname = "full_name"
        case urlString = "html_url"
        case starCount = "stargazers_count"
        case folkCount = "forks"
        case owner
    }
}

extension Repo: Then { }
