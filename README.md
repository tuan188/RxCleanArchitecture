# iOS Clean Architecture (MVVM + RxSwift)

## Introduction

RxCleanArchitecture is an example application built to demonstrate the usage of Clean Architecture along with MVVM and RxSwift frameworks in Swift.

## Installation

To install the necessary files using Swift Package Manager, follow these steps:

1. Open your Xcode project.
2. Select `File` > `Add Packages...`
3. Enter the URL of this repository: `https://github.com/tuan188/RxCleanArchitecture`
4. Select the appropriate package options and add the package to your project.

Alternatively, you can add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/tuan188/RxCleanArchitecture", .upToNextMajor(from: "6.0.0"))   
]
```

## Architecture

The architecture is structured into three main layers:

1. **Data Layer**: Responsible for data retrieval and manipulation: Gateway Implementations + API (Network) + Database
2. **Domain Layer**: Contains business logic and use cases: Entities + Use Cases + Gateway Protocols
3. **UI/Presentation Layer**: Manages user interface and user interactions: ViewModels + ViewControllers + Navigator

Each layer has a clear responsibility and communicates with other layers via protocols and RxSwift publishers.

<img width="600" alt="High Level Overview" src="images/high_level_overview.png">

**Dependency Direction**

<img width="500" alt="Dependency Direction" src="images/dependency_direction.png">


### Domain Layer

The Domain Layer contains the application’s business logic and use cases.

<img width="500" alt="Domain Layer" src="images/domain.png">

#### Entities
Entities encapsulate enterprise-wide Critical Business Rules. An entity can be an object with methods, or it can be a set of data structures and functions. It doesn’t matter so long as the entities can be used by many different applications in the enterprise. - _Clean Architecture: A Craftsman's Guide to Software Structure and Design (Robert C. Martin)_

Entities are simple data structures:

```swift
struct Product {
    var id = 0
    var name = ""
    var price = 0.0
}
```

#### Use Cases

The software in the use cases layer contains application-specific business rules. It encapsulates and implements all of the use cases of the system. These use cases orchestrate the flow of data to and from the entities, and direct those entities to use their Critical Business Rules to achieve the goals of the use case. - _Clean Architecture: A Craftsman's Guide to Software Structure and Design (Robert C. Martin)_

UseCases are protocols which do one specific thing:

```swift
protocol FetchRepos {
    var repoGateway: RepoGatewayProtocol { get }
}

extension FetchRepos {
    func fetchRepos(dto: FetchPageDto) -> Observable<PagingInfo<Repo>> {
        return repoGateway.fetchRepos(dto: dto)
    }
}
```

#### Gateway Protocols
Generally gateway is just another abstraction that will hide the actual implementation behind, similarly to the Facade Pattern. It could a Data Store (the Repository pattern), an API gateway, etc. Such as Database gateways will have methods to meet the demands of an application. However do not try to hide complex business rules behind such gateways. All queries to the database should relatively simple like CRUD operations, of course some filtering is also acceptable. - [Source](https://crosp.net/blog/software-architecture/clean-architecture-part-2-the-clean-architecture/)

```swift
protocol RepoGatewayProtocol {
    func fetchRepos(dto: FetchPageDto) -> Observable<PagingInfo<Repo>>
}
```

_Note: For simplicity we put the Gateway protocols and implementations in the same files. In fact, Gateway protocols should be at the Domain Layer and implementations at the Data Layer._

### Data Layer

<img width="500" alt="Data Layer" src="images/data.png">

Data Layer contains Gateway Implementations and one or many Data Stores. Gateways are responsible for coordinating data from different Data Stores. Data Store can be Remote or Local (for example persistent database). Data Layer depends only on the Domain Layer.

#### Gateway Implementations

```swift
struct RepoGateway: RepoGatewayProtocol {
    struct RepoList: Codable {
        let items: [Repo]
    }
    
    func fetchRepos(dto: FetchPageDto) -> Observable<PagingInfo<Repo>> {
        let (page, perPage) = (dto.page, dto.perPage)

        return APIServices.rxSwift
            .rx
            .request(GitEndpoint.repoList(page: page, perPage: perPage))
            .data(type: RepoList.self)
            .map { $0.items }
            .map { repos in
                return PagingInfo<Repo>(page: page, items: repos)
            }
    }
}
```

_Note: Again, for simplicity we put entities and mappings in the same files and use entities as data models for APIs. You can create data models for APIs and map to entities._

### Presentation Layer

<img width="500" alt="Presentation Layer" src="images/presentation.png">

In the current example, Presentation is implemented with the MVVM pattern and heavy use of RxSwift, which makes binding very easy.

<img width="500" alt="Presentation Layer" src="images/mvvm_pattern.png">

#### ViewModel

* ViewModel is the main point of MVVM application. The primary responsibility of the ViewModel is to provide data to the view, so that view can put that data on the screen.
* It also allows the user to interact with data and change the data.
* The other key responsibility of a ViewModel is to encapsulate the interaction logic for a view, but it does not mean that all of the logic of the application should go into ViewModel.
* It should be able to handle the appropriate sequencing of calls to make the right thing happen based on user or any changes on the view.
* ViewModel should also manage any navigation logic like deciding when it is time to navigate to a different view.
[Source](https://www.tutorialspoint.com/mvvm/mvvm_responsibilities.htm)

ViewModel performs pure transformation of a user Input to the Output:

```swift
public protocol ViewModel {
    associatedtype Input
    associatedtype Output
    
    func transform(_ input: Input, disposeBag: DisposeBag) -> Output
}
```

```swift
class ReposViewModel: FetchRepos, ShowRepoDetail {
    @Injected(\.repoGateway)
    var repoGateway: RepoGatewayProtocol
    
    unowned var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func getRepoList(page: Int) -> Observable<PagingInfo<Repo>> {
        return fetchRepos(dto: FetchPageDto(page: page, perPage: 10, usingCache: true))
    }
    
    func vm_showRepoDetail(repo: Repo) {
        showRepoDetail(repo: repo)
    }
}

// MARK: - ViewModel
extension ReposViewModel: ViewModel {
    struct Input {
        let load: Driver<Void>
        let reload: Driver<Void>
        let loadMore: Driver<Void>
        let selectRepo: Driver<IndexPath>
    }

    struct Output {
        @Property var error: Error?
        @Property var isLoading = false
        @Property var isReloading = false
        @Property var isLoadingMore = false
        @Property var repoList = [RepoItemViewModel]()
        @Property var isEmpty = false
    }

    func transform(_ input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        let config = PageFetchConfig(
            loadTrigger: input.load,
            reloadTrigger: input.reload,
            loadMoreTrigger: input.loadMore,
            fetchItems: { [unowned self] page in
                getRepoList(page: page)
            })
        
        let (page, pagingError, isLoading, isReloading, isLoadingMore) = fetchPage(config: config).destructured

        let repoList = page
            .map { $0.items }
            
        repoList
            .map { $0.map(RepoItemViewModel.init) }
            .drive(output.$repoList)
            .disposed(by: disposeBag)

        selectItem(at: input.selectRepo, from: repoList)
            .drive(onNext: vm_showRepoDetail)
            .disposed(by: disposeBag)
        
        isDataEmpty(loadingTrigger: Driver.merge(isLoading, isReloading), dataItems: repoList)
            .drive(output.$isEmpty)
            .disposed(by: disposeBag)
        
        pagingError
            .drive(output.$error)
            .disposed(by: disposeBag)
        
        isLoading
            .drive(output.$isLoading)
            .disposed(by: disposeBag)
        
        isReloading
            .drive(output.$isReloading)
            .disposed(by: disposeBag)
        
        isLoadingMore
            .drive(output.$isLoadingMore)
            .disposed(by: disposeBag)

        return output
    }
}
```

A ViewModel can be injected into a ViewController via property injection or initializer. Here is how the dependency injection is set up using [Factory](https://github.com/hmlongco/Factory).

```swift
import Factory

extension Container {
    func reposViewController(navigationController: UINavigationController) -> Factory<ReposViewController> {
        return Factory(self) {
            let vc = ReposViewController.instantiate()
            let vm = ReposViewModel(navigationController: navigationController)
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
```

ViewModels provide data and functionality to be used by views:

```swift
struct UserItemViewModel {
    let name: String
    let gender: String
    let birthday: String
    
    init(user: User) {
        self.name = user.name
        self.gender = user.gender.name
        self.birthday = user.birthday.dateString()
    }
}
```

#### ViewController

Data binding is performed in the bindViewModel method of the ViewController:

```swift
final class ReposViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: PagingTableView!
    
    // MARK: - Properties
    
    var viewModel: ReposViewModel!
    var disposeBag = DisposeBag()
    
    private var repoList = [RepoItemViewModel]()

    ...

    func bindViewModel() {
        let input = ReposViewModel.Input(
            load: Driver.just(()),
            reload: tableView.refreshTrigger,
            loadMore: tableView.loadMoreTrigger,
            selectRepo: tableView.rx.itemSelected.asDriver()
        )
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        
        output.$repoList
            .asDriver()
            .do(onNext: { [unowned self] repoList in
                self.repoList = repoList
            })
            .drive(tableView.rx.items) { tableView, index, repo in
                return tableView.dequeueReusableCell(
                    for: IndexPath(row: index, section: 0),
                    cellType: RepoCell.self
                )
                .then {
                    $0.bindViewModel(repo)
                }
            }
            .disposed(by: disposeBag)
        
        output.$error
            .asDriver()
            .unwrap()
            .drive(rx.error)
            .disposed(by: disposeBag)
        
        output.$isLoading
            .asDriver()
            .drive(rx.isLoading)
            .disposed(by: disposeBag)
        
        output.$isReloading
            .asDriver()
            .drive(tableView.isRefreshing)
            .disposed(by: disposeBag)
        
        output.$isLoadingMore
            .asDriver()
            .drive(tableView.isLoadingMore)
            .disposed(by: disposeBag)
        
        output.$isEmpty
            .asDriver()
            .drive(tableView.isEmpty)
            .disposed(by: disposeBag)
    }
}
```

## Testing
### What to test?
In this architecture, we can test Use Cases, ViewModels and Entities (if they contain business logic) using RxTest.

#### Use Case

```swift
final class GettingProductListTests: XCTestCase, FetchProductList {
    var productGateway: ProductGatewayProtocol {
        return productGatewayMock
    }
    
    private var productGatewayMock: ProductGatewayMock!
    private var disposeBag: DisposeBag!
    private var getProductListOutput: TestableObserver<PagingInfo<Product>>!
    private var scheduler: TestScheduler!

    override func setUp() {
        super.setUp()
        productGatewayMock = ProductGatewayMock()
        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
        getProductListOutput = scheduler.createObserver(PagingInfo<Product>.self)
    }

    func test_getProductList() {
        // act
        self.fetchProducts(dto: FetchPageDto(page: 1))
            .subscribe(getProductListOutput)
            .disposed(by: disposeBag)

        // assert
        XCTAssert(productGatewayMock.getProductListCalled)
        XCTAssertEqual(getProductListOutput.firstEventElement?.items.count, 1)
    }
    
    func test_getProductList_fail() {
        // assign
        productGatewayMock.getProductListReturnValue = Observable.error(TestError())

        // act
        self.fetchProducts(dto: FetchPageDto(page: 1))
            .subscribe(getProductListOutput)
            .disposed(by: disposeBag)

        // assert
        XCTAssert(productGatewayMock.getProductListCalled)
        XCTAssertEqual(getProductListOutput.events, [.error(0, TestError())])
    }

}
```

#### ViewModel

```swift
final class ReposViewModelTests: XCTestCase {
    private var viewModel: TestReposViewModel!
    private var input: ReposViewModel.Input!
    private var output: ReposViewModel.Output!
    private var disposeBag: DisposeBag!

    // Triggesr
    private let loadTrigger = PublishSubject<Void>()
    private let reloadTrigger = PublishSubject<Void>()
    private let loadMoreTrigger = PublishSubject<Void>()
    private let selectRepoTrigger = PublishSubject<IndexPath>()

    override func setUp() {
        super.setUp()
        viewModel = TestReposViewModel(navigationController: UINavigationController())
        
        input = ReposViewModel.Input(
            load: loadTrigger.asDriverOnErrorJustComplete(),
            reload: reloadTrigger.asDriverOnErrorJustComplete(),
            loadMore: loadMoreTrigger.asDriverOnErrorJustComplete(),
            selectRepo: selectRepoTrigger.asDriverOnErrorJustComplete()
        )
        
        disposeBag = DisposeBag()
        output = viewModel.transform(input, disposeBag: disposeBag)
    }

    func test_loadTriggerInvoked_getRepoList() {
        // act
        loadTrigger.onNext(())
        
        // assert
        XCTAssert(viewModel.getRepoListCalled)
        XCTAssertEqual(output.repoList.count, 1)
    }

    func test_loadTriggerInvoked_getRepoList_failedShowError() {
        // arrange
        viewModel.getRepoListResult = .error(TestError())

        // act
        loadTrigger.onNext(())

        // assert
        XCTAssert(viewModel.getRepoListCalled)
        XCTAssert(output.error is TestError)
    }

    ...
}

class TestReposViewModel: ReposViewModel {
    var getRepoListCalled: Bool = false
    var getRepoListResult: Observable<PagingInfo<Repo>> = .just(PagingInfo(page: 1, items: [Repo.mock()]))
    
    override func getRepoList(page: Int) -> Observable<PagingInfo<Repo>> {
        getRepoListCalled = true
        return getRepoListResult
    }
    
    var showRepoDetailCalled: Bool = false
    
    override func vm_showRepoDetail(repo: Repo) {
        showRepoDetailCalled = true
    }
}
```

## Example
<img alt="Example" src="images/example.jpg">


## Related
* [Clean Architecture (Combine + SwiftUI/UIKit)](https://github.com/tuan188/CleanArchitecture)
* [GitHub - sergdort/CleanArchitectureRxSwift: Example of Clean Architecture of iOS app using RxSwift](https://github.com/sergdort/CleanArchitectureRxSwift)
* [RxSwift: Clean Architecture, MVVM và RxSwift (Phần 1) - Viblo](https://viblo.asia/p/rxswift-clean-architecture-mvvm-va-rxswift-phan-1-gAm5yaR85db)
* [RxSwift: Clean Architecture, MVVM và RxSwift (Phần 2) - Viblo](https://viblo.asia/p/rxswift-clean-architecture-mvvm-va-rxswift-phan-2-E375zWR6KGW)
