//
//  MainViewModelTests.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/4/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

@testable import CleanArchitecture
import XCTest
import RxSwift

final class MainViewModelTests: XCTestCase {
    
    private var viewModel: TestMainViewModel!
    private var input: MainViewModel.Input!
    private var output: MainViewModel.Output!
    private var disposeBag: DisposeBag!

    // Triggers
    private let loadTrigger = PublishSubject<Void>()
    private let selectMenuTrigger = PublishSubject<IndexPath>()
    
    override func setUp() {
        super.setUp()
        viewModel = TestMainViewModel(navigationController: UINavigationController())
        
        input = MainViewModel.Input(
            load: loadTrigger.asDriverOnErrorJustComplete(),
            selectMenu: selectMenuTrigger.asDriverOnErrorJustComplete()
        )
        
        disposeBag = DisposeBag()
        output = viewModel.transform(input, disposeBag: disposeBag)
    }
    
    func test_loadTriggerInvoked_loadMenuList() {
        // act
        loadTrigger.onNext(())
        
        // assert
        XCTAssertEqual(output.menuSections.count, 4)
    }
    
    private func indexPath(of menu: MainViewModel.Menu) -> IndexPath? {
        let menuSections = viewModel.menuSections()
        
        for (section, menuSection) in menuSections.enumerated() {
            for (row, aMenu) in menuSection.menus.enumerated() {
                if aMenu == menu { // swiftlint:disable:this for_where
                    return IndexPath(row: row, section: section)
                }
            }
        }
        
        return nil
    }
    
    func test_selectMenuTriggerInvoked_toProductList() {
        // act
        loadTrigger.onNext(())
        
        guard let indexPath = indexPath(of: .products) else {
            XCTFail()
            return
        }
        
        selectMenuTrigger.onNext(indexPath)
        
        // assert
        XCTAssert(viewModel.showProductsCalled)
    }
    
    func test_selectMenuTriggerInvoked_toSectionedProductList() {
        // act
        loadTrigger.onNext(())
        
        guard let indexPath = indexPath(of: .sectionedProducts) else {
            XCTFail()
            return
        }
        
        selectMenuTrigger.onNext(indexPath)
        
        // assert
        XCTAssert(viewModel.showSectionedProductsCalled)
    }
    
    func test_selectMenuTriggerInvoked_toRepoList() {
        // act
        loadTrigger.onNext(())
        
        guard let indexPath = indexPath(of: .repos) else {
            XCTFail()
            return
        }
        
        selectMenuTrigger.onNext(indexPath)
        
        // assert
        XCTAssert(viewModel.showReposCalled)
    }
    
    func test_selectMenuTriggerInvoked_toRepoCollection() {
        // act
        loadTrigger.onNext(())
        
        guard let indexPath = indexPath(of: .repoCollection) else {
            XCTFail()
            return
        }
        
        selectMenuTrigger.onNext(indexPath)
        
        // assert
        XCTAssert(viewModel.showRepoCollectionCalled)
    }
    
    func test_selectMenuTriggerInvoked_toUsers() {
        // act
        loadTrigger.onNext(())
        
        guard let indexPath = indexPath(of: .users) else {
            XCTFail()
            return
        }
        
        selectMenuTrigger.onNext(indexPath)
        
        // assert
        XCTAssert(viewModel.showUsersCalled)
    }
    
    func test_selectMenuTriggerInvoked_toLogin() {
        // act
        loadTrigger.onNext(())
        
        guard let indexPath = indexPath(of: .login) else {
            XCTFail()
            return
        }
        
        selectMenuTrigger.onNext(indexPath)
        
        // assert
        XCTAssert(viewModel.showLoginCalled)
    }
}

class TestMainViewModel: MainViewModel {
    var showLoginCalled: Bool = false
    
    override func vm_showLogin() {
        showLoginCalled = true
    }
    
    var showProductsCalled: Bool = false
    
    override func vm_showProducts() {
        showProductsCalled = true
    }
    
    var showRepoCarouselCalled: Bool = false
    
    override func vm_showRepoCarousel() {
        showRepoCarouselCalled = true
    }
    
    var showUsersCalled: Bool = false
    
    override func vm_showUsers() {
        showUsersCalled = true
    }
    
    var showReposCalled: Bool = false
    
    override func vm_showRepos() {
        showReposCalled = true
    }
    
    var showRepoCollectionCalled: Bool = false
    
    override func vm_showRepoCollection() {
        showRepoCollectionCalled = true
    }
    
    var showSectionedProductsCalled: Bool = false
    
    override func vm_showSectionedProducts() {
        showSectionedProductsCalled = true
    }
    
    var showSectionedProductCollectionCalled: Bool = false
    
    override func vm_showSectionedProductCollection() {
        showSectionedProductCollectionCalled = true
    }
}
