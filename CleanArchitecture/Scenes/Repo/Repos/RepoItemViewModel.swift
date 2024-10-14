//
//  RepoItemViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 9/5/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import UIKit

struct RepoItemViewModel {
    let name: String
    let url: URL?
    
    init(repo: Repo) {
        self.name = repo.name
        self.url = URL(string: repo.owner.avatarURLString)
    }
}
