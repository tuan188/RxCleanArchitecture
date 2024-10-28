import UIKit
import ESPullToRefresh

/// A custom header animator for `ESPullToRefresh` that displays an arrow image and activity indicator for pull-to-refresh functionality.
open class RefreshHeaderAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol, ESRefreshImpactProtocol {
    
    /// The view associated with this animator.
    open var view: UIView { return self }
    
    /// The insets used for the refresh view.
    open var insets = UIEdgeInsets.zero
    
    /// The threshold (in points) that triggers the refresh action.
    open var trigger: CGFloat = 60.0
    
    /// The distance (in points) the content offset needs to move after the trigger point for the action to execute.
    open var executeIncremental: CGFloat = 60.0
    
    /// The current state of the refresh view.
    open var state: ESRefreshViewState = .pullToRefresh
    
    /// An image view displaying an arrow icon to indicate the pull-to-refresh action.
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        let frameworkBundle = Bundle(for: ESRefreshAnimator.self)
        if /* CocoaPods static */ let path = frameworkBundle.path(forResource: "ESPullToRefresh", ofType: "bundle"),
            let bundle = Bundle(path: path) {
            imageView.image = UIImage(named: "icon_pull_to_refresh_arrow", in: bundle, compatibleWith: nil)
        } else if /* Carthage */ let bundle = Bundle(identifier: "com.eggswift.ESPullToRefresh") {
            imageView.image = UIImage(named: "icon_pull_to_refresh_arrow", in: bundle, compatibleWith: nil)
        } else if /* CocoaPods */ let bundle = Bundle(identifier: "org.cocoapods.ESPullToRefresh") {
            imageView.image = UIImage(named: "ESPullToRefresh.bundle/icon_pull_to_refresh_arrow",
                                      in: bundle,
                                      compatibleWith: nil)
        } else /* Manual */ {
            imageView.image = UIImage(named: "icon_pull_to_refresh_arrow")
        }
        return imageView
    }()
    
    /// A label that displays the status of the pull-to-refresh action.
    private let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor(white: 0.625, alpha: 1.0)
        label.textAlignment = .left
        return label
    }()
    
    /// An activity indicator to display while refreshing.
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
    
    /// Initializes a new header animator with the specified frame.
    /// - Parameter frame: The frame rectangle for the view, measured in points.
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(imageView)
        self.addSubview(titleLabel)
        self.addSubview(indicatorView)
    }
    
    /// Initializes a new header animator from data in a given unarchiver.
    /// This initializer is unavailable and will cause a runtime error if called.
    /// - Parameter aDecoder: An unarchiver object.
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Begins the refresh animation by starting the activity indicator and hiding the arrow image.
    /// - Parameter view: The component view associated with the refresh action.
    open func refreshAnimationBegin(view: ESRefreshComponent) {
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        imageView.isHidden = true
        imageView.transform = CGAffineTransform(rotationAngle: 0.000_001 - CGFloat.pi)
    }
    
    /// Ends the refresh animation by stopping the activity indicator and showing the arrow image.
    /// - Parameter view: The component view associated with the refresh action.
    open func refreshAnimationEnd(view: ESRefreshComponent) {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
        imageView.isHidden = false
        imageView.transform = CGAffineTransform.identity
    }
    
    /// Updates the refresh view based on the current progress of the pull gesture.
    /// - Parameters:
    ///   - view: The component view associated with the refresh action.
    ///   - progress: A `CGFloat` value representing the current progress of the pull.
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
        
        switch state {
        case .refreshing, .autoRefreshing:
            self.setNeedsLayout()
        case .releaseToRefresh:
            self.setNeedsLayout()
            self.impact()
            UIView.animate(
                withDuration: 0.2,
                delay: 0.0,
                options: [],
                animations: { [weak self] in
                    self?.imageView.transform = CGAffineTransform(rotationAngle: 0.000_001 - CGFloat.pi)
                }
            )
        case .pullToRefresh:
            self.setNeedsLayout()
            UIView.animate(
                withDuration: 0.2,
                delay: 0.0,
                options: [],
                animations: { [weak self] in
                    self?.imageView.transform = CGAffineTransform.identity
                }
            )
        default:
            break
        }
    }
    
    /// Lays out subviews by positioning the image, label, and activity indicator within the bounds of the view.
    override open func layoutSubviews() {
        super.layoutSubviews()
        let size = self.bounds.size
        let width = size.width
        let height = size.height
        
        UIView.performWithoutAnimation {
            indicatorView.center = CGPoint(x: width / 2.0, y: height / 2.0)
            imageView.frame = CGRect(x: titleLabel.frame.origin.x - 28.0,
                                     y: (height - 18.0) / 2.0,
                                     width: 18.0,
                                     height: 18.0)
        }
    }
}
