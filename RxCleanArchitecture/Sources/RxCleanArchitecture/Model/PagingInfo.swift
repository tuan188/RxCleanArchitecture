/// A struct representing paginated information for a collection of items.
public struct PagingInfo<T> {
    
    /// The current page number.
    public var page: Int
    
    /// The items in the current page.
    public var items: [T]
    
    /// A Boolean value indicating whether there are more pages available after the current page.
    public var hasMorePages: Bool
    
    /// The total number of items across all pages.
    public var totalItems: Int
    
    /// The number of items per page.
    public var itemsPerPage: Int
    
    /// The total number of pages available.
    public var totalPages: Int
    
    /// Creates a new instance of `PagingInfo`.
    ///
    /// - Parameters:
    ///   - page: The current page number. Defaults to 1.
    ///   - items: The items in the current page. Defaults to an empty array.
    ///   - hasMorePages: A Boolean value indicating whether there are more pages. Defaults to `true`.
    ///   - totalItems: The total number of items across all pages. Defaults to 0.
    ///   - itemsPerPage: The number of items per page. Defaults to 0.
    ///   - totalPages: The total number of pages available. Defaults to 0.
    public init(page: Int = 1,
                items: [T] = [],
                hasMorePages: Bool = true,
                totalItems: Int = 0,
                itemsPerPage: Int = 0,
                totalPages: Int = 0) {
        self.page = page
        self.items = items
        self.hasMorePages = hasMorePages
        self.totalItems = totalItems
        self.itemsPerPage = itemsPerPage
        self.totalPages = totalPages
    }
}

extension PagingInfo: Equatable where T: Equatable {
    public static func == (lhs: PagingInfo<T>, rhs: PagingInfo<T>) -> Bool {
        return lhs.page == rhs.page
            && lhs.items == rhs.items
    }
}
