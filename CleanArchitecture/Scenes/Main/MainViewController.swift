//
//  MainViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/4/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable
import SDWebImage
import RxSwift
import RxCocoa
import Factory

final class MainViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties

    var viewModel: MainViewModel!
    var disposeBag = DisposeBag()
    
    private var menuSections = [MainViewModel.MenuSection]()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        SDImageCache.shared.clearMemory()
        SDImageCache.shared.clearDisk()
    }
    
    deinit {
        logDeinit()
    }
    
    // MARK: - Methods
    
    private func configView() {
        tableView.do {
            $0.register(cellType: MenuCell.self)
            $0.delegate = self
            $0.dataSource = self
            $0.rowHeight = 60
        }
        
        view.backgroundColor = ColorCompatibility.systemBackground
    }
    
    func bindViewModel() {
        let input = MainViewModel.Input(
            load: Driver.just(()),
            selectMenu: tableView.rx.itemSelected.asDriver()
        )
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        
        output.$menuSections
            .asDriver()
            .drive(onNext: { [unowned self] sections in
                self.menuSections = sections
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return menuSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuSections[section].menus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menu = menuSections[indexPath.section].menus[indexPath.row]
        
        return tableView.dequeueReusableCell(for: indexPath, cellType: MenuCell.self)
            .then {
                $0.titleLabel.text = menu.description
            }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return menuSections[section].title
    }
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - StoryboardSceneBased
extension MainViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.main
}

extension Container {
    func mainViewController(navigationController: UINavigationController) -> Factory<MainViewController> {
        Factory(self) {
            let vc = MainViewController.instantiate()
            let vm: MainViewModel = MainViewModel(navigationController: navigationController)
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
