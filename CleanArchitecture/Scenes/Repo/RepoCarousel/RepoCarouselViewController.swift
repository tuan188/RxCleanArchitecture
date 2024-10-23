//
//  RepoCarouselViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 15/12/2020.
//  Copyright © 2020 Sun Asterisk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Reusable
import Then
import SDWebImage
import Factory
import RxCleanArchitecture

final class RepoCarouselViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var collectionView: PagingCollectionView!
    
    // MARK: - Properties
    
    var viewModel: RepoCarouselViewModel!
    var disposeBag = DisposeBag()
    
    private var selectRepoTrigger = PublishSubject<IndexPath>()
    private var sections = [PageSectionViewModel]()
    private var storedOffsets = [Int: CGFloat]()
    
    static let sectionLayoutDictionary: [SectionType: SectionLayout] = {
        let sectionLayouts = [
            ListSectionLayout(),
            CardSectionLayout(),
            CarouselSectionLayout()
        ]
        
        var sectionLayoutDictionary = [SectionType: SectionLayout]()
        
        for layout in sectionLayouts {
            sectionLayoutDictionary[layout.sectionType] = layout
        }
        
        return sectionLayoutDictionary
    }()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }

    deinit {
        logDeinit()
    }
    
    // MARK: - Methods
    
    private func configView() {
        // register cells
        for layout in RepoCarouselViewController.sectionLayoutDictionary.values {
            collectionView.register(cellType: layout.cellType.self)
        }
        
        collectionView.do {
            $0.delegate = self
            $0.dataSource = self
            $0.prefetchDataSource = self
            $0.alwaysBounceVertical = true
            $0.backgroundColor = ColorCompatibility.systemBackground
            $0.refreshFooter = nil
        }
        
        view.backgroundColor = ColorCompatibility.systemBackground
    }

    func bindViewModel() {
        let input = RepoCarouselViewModel.Input(
            load: Driver.just(()),
            reload: collectionView.refreshTrigger,
            selectRepo: selectRepoTrigger.asDriverOnErrorJustComplete()
        )
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        
        output.$sections
            .asDriver()
            .drive(onNext: { [unowned self] sections in
                self.sections = sections
                self.collectionView.reloadData()
            })
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
            .drive(collectionView.isRefreshing)
            .disposed(by: disposeBag)
        
        output.$isEmpty
            .asDriver()
            .drive(collectionView.isEmpty)
            .disposed(by: disposeBag)
    }
}

// MARK: - Layout support methods
extension RepoCarouselViewController {
    private func sectionLayout(for section: Int, collectionView: UICollectionView) -> SectionLayout {
        let pageSection = self.pageSection(for: section, collectionView: collectionView)
        return sectionLayout(for: pageSection.type)
    }
    
    private func sectionLayout(for type: SectionType) -> SectionLayout {
        return RepoCarouselViewController.sectionLayoutDictionary[type]!  // swiftlint:disable:this force_unwrapping
    }
    
    private func pageSection(for section: Int, collectionView: UICollectionView) -> PageSectionViewModel {
        let sectionIndex = collectionView == self.collectionView
            ? section
            : collectionView.tag
        return sections[sectionIndex]
    }
    
    private func layoutOptions(for section: Int, collectionView: UICollectionView) -> LayoutOptions {
        let layout = self.sectionLayout(for: section, collectionView: collectionView)
        
        if collectionView is CarouselCollectionView {
            return layout.childLayout!  // swiftlint:disable:this force_unwrapping
        }
        
        return layout.layout
    }
    
    private func getSizeOfItem(_ collectionView: UICollectionView,
                               at indexPath: IndexPath,
                               with sectionInfo: SectionLayout,
                               and layout: LayoutOptions) -> CGSize {
        if collectionView === self.collectionView && sectionInfo.hasChild {
            return CGSize(width: layout.itemAutoWidth,
                          height: layout.itemHeight)
        }
        
        return layout.itemSize
    }
}

// MARK: - UICollectionViewDataSource
extension RepoCarouselViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if collectionView is CarouselCollectionView {
            return 1
        }
        
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let pageSection = self.pageSection(for: section, collectionView: collectionView)
        let sectionLayout = self.sectionLayout(for: pageSection.type)
        let isChildCollectionView = !(collectionView === self.collectionView)
        
        if isChildCollectionView {
            return pageSection.items.count
        }
        
        return sectionLayout.hasChild ? 1 : pageSection.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let pageSection = self.pageSection(for: indexPath.section, collectionView: collectionView)
        let sectionLayout = self.sectionLayout(for: pageSection.type)
        let isChildCollectionView = !(collectionView === self.collectionView)
        let viewModel = sections[indexPath.section].items[indexPath.row]
        
        return collectionView.dequeueReusableCell(
            for: indexPath,
            cellType: isChildCollectionView
                ? sectionLayout.childCellType!  // swiftlint:disable:this force_unwrapping
                : sectionLayout.cellType
        )
        .then {
            $0.bindViewModel(viewModel)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension RepoCarouselViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Set Collection View's Estimate Size to None in Storyboard
        let sectionLayout = self.sectionLayout(for: sections[indexPath.section].type)
        let layout = layoutOptions(for: indexPath.section, collectionView: collectionView)
        return getSizeOfItem(collectionView, at: indexPath, with: sectionLayout, and: layout)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        let layout = layoutOptions(for: section, collectionView: collectionView)
        return layout.sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let layout = layoutOptions(for: section, collectionView: collectionView)
        return layout.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let layout = layoutOptions(for: section, collectionView: collectionView)
        return layout.itemSpacing
    }
}

// MARK: - UICollectionViewDelegate
extension RepoCarouselViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedIndexPath: IndexPath
        
        if collectionView === self.collectionView {
            selectedIndexPath = indexPath
        } else {
            selectedIndexPath = IndexPath(row: indexPath.row, section: collectionView.tag)
        }
        
        selectRepoTrigger.onNext(selectedIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? CarouselCellType {
            cell.setCollectionViewDataSourceDelegate(self, for: indexPath.section)
            cell.collectionViewOffset = storedOffsets[indexPath.section] ?? 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? CarouselCellType {
            storedOffsets[indexPath.section] = cell.collectionViewOffset
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching
extension RepoCarouselViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {

    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        
    }
}

// MARK: - StoryboardSceneBased
extension RepoCarouselViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.repo
}

extension Container {
    func repoCarouselViewController(navigationController: UINavigationController) -> Factory<RepoCarouselViewController> {
        Factory(self) {
            let vc = RepoCarouselViewController.instantiate()
            let vm = RepoCarouselViewModel(navigationController: navigationController)
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
