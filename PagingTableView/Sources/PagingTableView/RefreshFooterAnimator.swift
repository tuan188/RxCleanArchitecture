import UIKit
import ESPullToRefresh

/// A custom footer animator for `ESPullToRefresh` that shows an activity indicator when loading more content.
open class RefreshFooterAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol {
    
    /// The view associated with this animator.
    open var view: UIView { return self }
    
    /// The duration of the animation.
    open var duration: TimeInterval = 0.3
    
    /// The insets used for the refresh view.
    open var insets = UIEdgeInsets.zero
    
    /// The threshold (in points) that triggers the refresh action.
    open var trigger: CGFloat = 42.0
    
    /// The distance (in points) the content offset needs to move after the trigger point for the action to execute.
    open var executeIncremental: CGFloat = 42.0
    
    /// The current state of the refresh view.
    open var state: ESRefreshViewState = .pullToRefresh
    
    /// An activity indicator to display while loading more content.
    private let indicatorView: UIActivityIndicatorView = {
        let indicatorView: UIActivityIndicatorView
        
        // Sets the style of the activity indicator based on the iOS version.
        if #available(iOS 13.0, *) {
            indicatorView = UIActivityIndicatorView(style: .medium)
        } else {
            indicatorView = UIActivityIndicatorView(style: .gray)
        }
        
        indicatorView.isHidden = true
        return indicatorView
    }()
    
    /// Initializes a new footer animator with the specified frame.
    /// - Parameter frame: The frame rectangle for the view, measured in points.
    override public init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(indicatorView)
    }
    
    /// Initializes a new footer animator from data in a given unarchiver.
    /// This initializer is unavailable and will cause a runtime error if called.
    /// - Parameter aDecoder: An unarchiver object.
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Begins the refresh animation.
    /// - Parameter view: The component view associated with the refresh action.
    open func refreshAnimationBegin(view: ESRefreshComponent) {
        indicatorView.startAnimating()
        indicatorView.isHidden = false
    }
    
    /// Ends the refresh animation.
    /// - Parameter view: The component view associated with the refresh action.
    open func refreshAnimationEnd(view: ESRefreshComponent) {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
    }
    
    /// Updates the refresh view based on the current progress.
    /// - Parameters:
    ///   - view: The component view associated with the refresh action.
    ///   - progress: A `CGFloat` value representing the current progress.
    open func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {
        // No action needed for progress changes
    }
    
    /// Updates the refresh view based on the state change.
    /// - Parameters:
    ///   - view: The component view associated with the refresh action.
    ///   - state: The new state of the refresh view.
    open func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        guard self.state != state else { return }
        self.state = state
        self.setNeedsLayout()
    }
    
    /// Lays out subviews by centering the activity indicator within the bounds of the view.
    override open func layoutSubviews() {
        super.layoutSubviews()
        let size = self.bounds.size
        let width = size.width
        let height = size.height
        
        indicatorView.center = CGPoint(x: width / 2.0, y: height / 2.0 - 5.0)
    }
}
