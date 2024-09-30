//
//  UICollectionView+.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 9/5/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension UICollectionView {
    var isEmpty: Binder<Bool> {
        return Binder(self) { collectionView, isEmpty in
            if isEmpty {
                let frame = CGRect(x: 0,
                                   y: 0,
                                   width: collectionView.frame.size.width,
                                   height: collectionView.frame.size.height)
                let emptyView = EmptyDataView(frame: frame)
                collectionView.backgroundView = emptyView
            } else {
                collectionView.backgroundView = nil
            }
        }
    }
}
