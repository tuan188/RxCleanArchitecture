//
//  ScreenLoadingType.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 7/25/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

public enum ScreenLoadingType<Input> {
    case loading(Input)
    case reloading(Input)
}
