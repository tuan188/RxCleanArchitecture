//
//  AppDelegate.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 6/4/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import UIKit
//import MagicalRecord
import RxSwift
import RxCocoa
import SDWebImage
import Factory
import APIService
import APIServiceRx
import CoreStore

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var disposeBag = DisposeBag()
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        setupCoreData()
//        configSDWebImageDownloader()
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        APIServices.rxSwift.logger = APILoggers.verbose
        
        if NSClassFromString("XCTest") != nil { // test
            window.rootViewController = UnitTestViewController()
            window.makeKeyAndVisible()
        } else {
            bindViewModel(window: window)
        }
    }
    
    private func configSDWebImageDownloader() {
        let downloader = SDWebImageDownloader.shared
        downloader.config.username = "username"
        downloader.config.password = "password"
    }
    
    private func setupCoreData() {
        CoreStoreDefaults.dataStack = DataStack(
            xcodeModelName: "Model",
            bundle: Bundle.main
        )
        
        do {
            try CoreStoreDefaults.dataStack.addStorageAndWait(
                SQLiteStore(
                    fileName: "Model.sqlite",
                    localStorageOptions: .allowSynchronousLightweightMigration
                )
            )
        } catch {
            print(error)
        }
    }

    private func bindViewModel(window: UIWindow) {
        let vm: AppViewModel = Container.shared.appViewModel(window: window)()
        let input = AppViewModel.Input(load: Driver.just(()))
        vm.transform(input, disposeBag: disposeBag)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {

    }
}

