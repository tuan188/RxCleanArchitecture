//
//  ReposViewModelTests.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/28/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import RxSwift
import RxCleanArchitecture

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

    func test_reloadTriggerInvoked_getRepoList() {
        // act
        reloadTrigger.onNext(())

        // assert
        XCTAssert(viewModel.getRepoListCalled)
        XCTAssertEqual(output.repoList.count, 1)
    }

    func test_reloadTriggerInvoked_getRepoList_failedShowError() {
        // arrange
        viewModel.getRepoListResult = .error(TestError())

        // act
        reloadTrigger.onNext(())

        // assert
        XCTAssert(viewModel.getRepoListCalled)
        XCTAssert(output.error is TestError)
    }

    func test_reloadTriggerInvoked_notGetRepoListIfStillLoading() {
        // arrange
        viewModel.getRepoListResult = .never()

        // act
        loadTrigger.onNext(())
        viewModel.getRepoListCalled = false
        reloadTrigger.onNext(())

        // assert
        XCTAssertFalse(viewModel.getRepoListCalled)
    }

    func test_reloadTriggerInvoked_notGetRepoListIfStillReloading() {
        // arrange
        viewModel.getRepoListResult = .never()

        // act
        reloadTrigger.onNext(())
        viewModel.getRepoListCalled = false
        reloadTrigger.onNext(())

        // assert
        XCTAssertFalse(viewModel.getRepoListCalled)
    }

    func test_loadMoreTriggerInvoked_loadMoreRepoList() {
        // act
        loadTrigger.onNext(())
        loadMoreTrigger.onNext(())

        // assert
        XCTAssert(viewModel.getRepoListCalled)
        XCTAssertEqual(output.repoList.count, 2)
    }

    func test_loadMoreTriggerInvoked_loadMoreRepoList_failedShowError() {
        // arrange
        viewModel.getRepoListResult = .error(TestError())

        // act
        loadTrigger.onNext(())
        loadMoreTrigger.onNext(())

        // assert
        XCTAssert(viewModel.getRepoListCalled)
        XCTAssert(output.error is TestError)
    }

    func test_loadMoreTriggerInvoked_notLoadMoreRepoListIfStillLoading() {
        // arrange
        viewModel.getRepoListResult = .never()

        // act
        loadTrigger.onNext(())
        viewModel.getRepoListCalled = false
        loadMoreTrigger.onNext(())

        // assert
        XCTAssertFalse(viewModel.getRepoListCalled)
    }

    func test_loadMoreTriggerInvoked_notLoadMoreRepoListIfStillReloading() {
        // arrange
        viewModel.getRepoListResult = .never()

        // act
        reloadTrigger.onNext(())
        viewModel.getRepoListCalled = false
        loadMoreTrigger.onNext(())
        
        // assert
        XCTAssertFalse(viewModel.getRepoListCalled)
    }

    func test_loadMoreTriggerInvoked_notLoadMoreDocumentTypesStillLoadingMore() {
        // arrange
        viewModel.getRepoListResult = .never()
        
        // act
        loadMoreTrigger.onNext(())
        viewModel.getRepoListCalled = false
        loadMoreTrigger.onNext(())

        // assert
        XCTAssertFalse(viewModel.getRepoListCalled)
    }

    func test_selectRepoTriggerInvoked_toRepoDetail() {
        // act
        loadTrigger.onNext(())
        selectRepoTrigger.onNext(IndexPath(row: 0, section: 0))

        // assert
        XCTAssert(viewModel.showRepoDetailCalled)
    }
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
