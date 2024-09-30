//
//  PagingTableView.swift
//  MGLoadMore
//
//  Created by Tuan Truong on 9/4/20.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import ESPullToRefresh

open class PagingTableView: UITableView {
    private let _refreshControl = UIRefreshControl()
    
    open var isRefreshing: Binder<Bool> {
        return Binder(self) { tableView, loading in
            if tableView.refreshHeader == nil {
                if loading {
                    tableView._refreshControl.beginRefreshing()
                } else {
                    if tableView._refreshControl.isRefreshing {
                        tableView._refreshControl.endRefreshing()
                    }
                }
            } else {
                if loading {
                    tableView.es.startPullToRefresh()
                } else {
                    tableView.es.stopPullToRefresh()
                }
            }
        }
    }
    
    open var isLoadingMore: Binder<Bool> {
        return Binder(self) { tableView, loading in
            if loading {
                tableView.es.base.footer?.startRefreshing()
            } else {
                tableView.es.stopLoadingMore()
            }
        }
    }
    
    private var _refreshTrigger = PublishSubject<Void>()
    
    open var refreshTrigger: Driver<Void> {
        return Driver.merge(
            _refreshTrigger
                .filter { [weak self] in
                    self?.refreshHeader != nil
                }
                .asDriver(onErrorJustReturn: ()),
            _refreshControl.rx.controlEvent(.valueChanged)
                .filter { [weak self] in
                    self?.refreshHeader == nil
                }
                .asDriver(onErrorJustReturn: ())
        )
        
    }
    
    private var _loadMoreTrigger = PublishSubject<Void>()
    
    open var loadMoreTrigger: Driver<Void> {
        _loadMoreTrigger.asDriver(onErrorJustReturn: ())
    }
    
    open var refreshHeader: (ESRefreshProtocol & ESRefreshAnimatorProtocol)? {
        didSet {
            removeRefreshControl()
            removeRefreshHeader()
            
            guard let header = refreshHeader else { return }
            
            es.addPullToRefresh(animator: header) { [weak self] in
                self?._refreshTrigger.onNext(())
            }
        }
    }
    
    open var refreshFooter: (ESRefreshProtocol & ESRefreshAnimatorProtocol)? {
        didSet {
            removeRefreshFooter()
            
            guard let footer = refreshFooter else { return }
            
            es.addInfiniteScrolling(animator: footer) { [weak self] in
                self?._loadMoreTrigger.onNext(())
            }
        }
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        expiredTimeInterval = 20.0
        addRefreshControl()
        refreshFooter = RefreshFooterAnimator(frame: .zero)
    }
    
    open func addRefreshControl() {
        refreshHeader = nil
        
        if #available(iOS 10.0, *) {
            self.refreshControl = _refreshControl
        } else {
            guard !self.subviews.contains(_refreshControl) else { return }
            self.addSubview(_refreshControl)
        }
    }
    
    open func removeRefreshControl() {
        if #available(iOS 10.0, *) {
            self.refreshControl = nil
        } else {
            _refreshControl.removeFromSuperview()
        }
    }
    
    open func removeRefreshHeader() {
        es.removeRefreshHeader()
    }
    
    open func removeRefreshFooter() {
        es.removeRefreshFooter()
    }
    
}
