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

extension Owner {
    static func mock() -> Self {
        return .init(avatarURLString: "https://avatars1.githubusercontent.com/u/12345678?v=4")
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

extension Repo {
    static func mock() -> Self {
        return .init(
            id: 1,
            name: "Mock Repo",
            fullname: "Mock Repo",
            urlString: "https://github.com/SunAsterisk/CleanArchitecture",
            starCount: 1,
            folkCount: 1,
            owner: Owner.mock()
        )
    }
}
