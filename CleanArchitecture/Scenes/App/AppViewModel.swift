//
//  AppViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/4/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import MGArchitecture
import RxSwift
import RxCocoa
import Factory
import UIKit

class AppViewModel: SettingUpUserData, ShowMain {
    @Injected(\.appGateway)
    var appGateway: AppGatewayProtocol
    
    @Injected(\.userGateway)
    var userGateway: UserGatewayProtocol
    
    var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
}

// MARK: - ViewModel
extension AppViewModel: ViewModel {
    struct Input {
        let load: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) {
        input.load
            .flatMapLatest { [unowned self] in
                addUserData()
                    .asDriverOnErrorJustComplete()
            }
            .drive(onNext: { [unowned self] in
                showMain()
            })
            .disposed(by: disposeBag)
    }
}

extension Container {
    func appViewModel(window: UIWindow) -> Factory<AppViewModel> {
        Factory(self) {
            AppViewModel(window: window)
        }
    }
}
