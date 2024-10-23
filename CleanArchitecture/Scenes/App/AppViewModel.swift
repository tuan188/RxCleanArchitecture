//
//  AppViewModel.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/4/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa
import Factory
import UIKit
import RxCleanArchitecture

class AppViewModel: SettingUpUserData, ShowMain {
    @Injected(\.appGateway)
    var appGateway: AppGatewayProtocol
    
    @Injected(\.userGateway)
    var userGateway: UserGatewayProtocol
    
    var window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func vm_addUserData() -> Observable<Void> {
        addUserData()
    }
    
    func vm_showMain() {
        showMain()
    }
}

// MARK: - ViewModel
extension AppViewModel: ViewModel {
    struct Input {
        let load: Driver<Void>
    }
    
    func transform(_ input: Input, disposeBag: DisposeBag) {
        input.load
            .flatMapLatest {
                self.vm_addUserData()
                    .asDriverOnErrorJustComplete()
            }
            .drive(onNext: {
                self.vm_showMain()
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
