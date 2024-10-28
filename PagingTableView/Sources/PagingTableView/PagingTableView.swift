import UIKit
import RxCocoa
import RxSwift
import ESPullToRefresh

/// A `UITableView` subclass that supports pull-to-refresh and load-more functionality using RxSwift and ESPullToRefresh.
open class PagingTableView: UITableView {
    
    /// The standard UIRefreshControl instance used for pull-to-refresh.
    private let _refreshControl = UIRefreshControl()
    
    /// A `Binder` that controls the refreshing state of the table view.
    ///
    /// Bind `isRefreshing` to a Boolean value to start or stop the pull-to-refresh control based on the loading state.
    open var isRefreshing: Binder<Bool> {
        return Binder(self) { tableView, loading in
            if tableView.refreshHeader == nil {
                // Use UIRefreshControl if no ESPullToRefresh header is set
                if loading {
                    tableView._refreshControl.beginRefreshing()
                } else {
                    if tableView._refreshControl.isRefreshing {
                        tableView._refreshControl.endRefreshing()
                    }
                }
            } else {
                // Use ESPullToRefresh for a custom header if available
                if loading {
                    tableView.es.startPullToRefresh()
                } else {
                    tableView.es.stopPullToRefresh()
                }
            }
        }
    }
    
    /// A `Binder` that controls the loading-more state of the table view.
    ///
    /// Bind `isLoadingMore` to a Boolean value to start or stop the load-more control based on the loading state.
    open var isLoadingMore: Binder<Bool> {
        return Binder(self) { tableView, loading in
            if loading {
                // Starts the load-more footer animation
                tableView.es.base.footer?.startRefreshing()
            } else {
                // Stops the load-more footer animation
                tableView.es.stopLoadingMore()
            }
        }
    }
    
    /// A `PublishSubject` that emits events when pull-to-refresh is triggered.
    private var _refreshTrigger = PublishSubject<Void>()
    
    /// A `Driver` that emits an event when a refresh is triggered.
    ///
    /// This combines events from both ESPullToRefresh and UIRefreshControl based on availability.
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
    
    /// A `PublishSubject` that emits events when load-more is triggered.
    private var _loadMoreTrigger = PublishSubject<Void>()
    
    /// A `Driver` that emits an event when a load-more action is triggered.
    open var loadMoreTrigger: Driver<Void> {
        _loadMoreTrigger.asDriver(onErrorJustReturn: ())
    }
    
    /// A customizable refresh header that uses `ESPullToRefresh` protocol.
    ///
    /// When set, this property adds a custom pull-to-refresh header animator.
    open var refreshHeader: (ESRefreshProtocol & ESRefreshAnimatorProtocol)? {
        didSet {
            removeRefreshControl()
            removeRefreshHeader()
            
            guard let header = refreshHeader else { return }
            
            // Adds a custom pull-to-refresh animator header
            es.addPullToRefresh(animator: header) { [weak self] in
                self?._refreshTrigger.onNext(())
            }
        }
    }
    
    /// A customizable refresh footer that uses `ESPullToRefresh` protocol.
    ///
    /// When set, this property adds a custom load-more footer animator.
    open var refreshFooter: (ESRefreshProtocol & ESRefreshAnimatorProtocol)? {
        didSet {
            removeRefreshFooter()
            
            guard let footer = refreshFooter else { return }
            
            // Adds a custom infinite scrolling animator footer
            es.addInfiniteScrolling(animator: footer) { [weak self] in
                self?._loadMoreTrigger.onNext(())
            }
        }
    }
    
    /// Initializes the table view from a nib file.
    ///
    /// Sets the default refresh control and footer.
    override open func awakeFromNib() {
        super.awakeFromNib()
        expiredTimeInterval = 20.0
        addRefreshControl()
        refreshFooter = RefreshFooterAnimator(frame: .zero)
    }
    
    /// Adds the default `UIRefreshControl` for pull-to-refresh if no custom header is set.
    open func addRefreshControl() {
        refreshHeader = nil
        
        if #available(iOS 10.0, *) {
            self.refreshControl = _refreshControl
        } else {
            // For iOS versions below 10.0, add refresh control as a subview
            guard !self.subviews.contains(_refreshControl) else { return }
            self.addSubview(_refreshControl)
        }
    }
    
    /// Removes the default `UIRefreshControl` if it is present.
    open func removeRefreshControl() {
        if #available(iOS 10.0, *) {
            self.refreshControl = nil
        } else {
            _refreshControl.removeFromSuperview()
        }
    }
    
    /// Removes the custom ESPullToRefresh header from the table view.
    open func removeRefreshHeader() {
        es.removeRefreshHeader()
    }
    
    /// Removes the custom ESPullToRefresh footer from the table view.
    open func removeRefreshFooter() {
        es.removeRefreshFooter()
    }
}
