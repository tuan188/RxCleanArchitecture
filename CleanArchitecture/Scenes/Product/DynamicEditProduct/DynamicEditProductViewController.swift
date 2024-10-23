//
//  DynamicEditProductViewController.swift
//  CleanArchitecture
//
//  Created by Tuan Truong on 9/10/18.
//  Copyright © 2018 Sun Asterisk. All rights reserved.
//

import UIKit
import Reusable
import ValidatedPropertyKit
import RxSwift
import RxCocoa
import Factory
import RxCleanArchitecture

final class DynamicEditProductViewController: UIViewController, Bindable {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var updateButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    var viewModel: DynamicEditProductViewModel!
    var disposeBag = DisposeBag()
    
    private weak var nameTextField: UITextField?
    private weak var priceTextField: UITextField?
    private weak var nameValidationLabel: UILabel?
    private weak var priceValidationLabel: UILabel?
    
    private let dataTrigger = PublishSubject<DynamicEditProductViewModel.DataType>()
    private let endEditTrigger = PublishSubject<Void>()
    private var cells = [DynamicEditProductViewModel.Cell]()
    
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
        tableView.do {
            $0.rowHeight = 70
            $0.register(cellType: EditProductNameCell.self)
            $0.register(cellType: EditProductPriceCell.self)
            $0.tableFooterView = UIView()
            $0.keyboardDismissMode = .onDrag
            $0.dataSource = self
        }
    }

    func bindViewModel() {
        let loadTrigger = Driver.merge(
            endEditTrigger.map { DynamicEditProductViewModel.TriggerType.endEditing }
                .asDriverOnErrorJustComplete(),
            rx.sentMessage(#selector(viewWillAppear(_:)))
                .take(1)
                .map { _ in DynamicEditProductViewModel.TriggerType.load }
                .asDriverOnErrorJustComplete()
        )
        
        let input = DynamicEditProductViewModel.Input(
            load: loadTrigger,
            update: updateButton.rx.tap.asDriver(),
            cancel: cancelButton.rx.tap.asDriver(),
            data: dataTrigger.asDriverOnErrorJustComplete()
        )
        
        let output = viewModel.transform(input, disposeBag: disposeBag)
        
        output.$cellCollection
            .asDriver()
            .drive(cellCollectionBinder)
            .disposed(by: disposeBag)
        
        output.$nameValidation
            .asDriver()
            .drive(nameValidationBinder)
            .disposed(by: disposeBag)
        
        output.$priceValidation
            .asDriver()
            .drive(priceValidationBinder)
            .disposed(by: disposeBag)
        
        output.$isUpdateEnabled
            .asDriver()
            .drive(updateButton.rx.isEnabled)
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
    }
}

// MARK: - Binders
extension DynamicEditProductViewController {
    var nameValidationBinder: Binder<ValidationResult> {
        return Binder(self) { vc, validation in
            let viewModel = ValidationResultViewModel(validationResult: validation)
            vc.nameTextField?.backgroundColor = viewModel.backgroundColor
            vc.nameValidationLabel?.text = viewModel.text
        }
    }
    
    var priceValidationBinder: Binder<ValidationResult> {
        return Binder(self) { vc, validation in
            let viewModel = ValidationResultViewModel(validationResult: validation)
            vc.priceTextField?.backgroundColor = viewModel.backgroundColor
            vc.priceValidationLabel?.text = viewModel.text
        }
    }
    
    var cellCollectionBinder: Binder<DynamicEditProductViewModel.CellCollection> {
        return Binder(self) { vc, cellCollection in
            vc.cells = cellCollection.cells
            
            if cellCollection.needsReloading {
                vc.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension DynamicEditProductViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cells[indexPath.row]
        let viewModel = ValidationResultViewModel(validationResult: cell.validationResult)
        
        switch cell.dataType {
        case let .name(name):
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EditProductNameCell.self)
                .then {
                    $0.nameTextField.text = name
                    $0.nameTextField.backgroundColor = viewModel.backgroundColor
                    $0.validationLabel.text = viewModel.text
                }
            
            cell.nameTextField.rx.text.orEmpty
                .subscribe(onNext: { [unowned self] text in
                    self.dataTrigger.onNext(DynamicEditProductViewModel.DataType.name(text))
                })
                .disposed(by: cell.disposeBag)
            
            cell.nameTextField.rx.controlEvent(UIControl.Event.editingDidEnd)
                .subscribe(onNext: { [unowned self] _ in
                    self.endEditTrigger.onNext(())
                })
                .disposed(by: cell.disposeBag)
            
            nameTextField = cell.nameTextField
            nameValidationLabel = cell.validationLabel
            
            return cell
        case let .price(price):
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EditProductPriceCell.self)
                .then {
                    $0.priceTextField.text = price
                    $0.priceTextField.backgroundColor = viewModel.backgroundColor
                    $0.validationLabel.text = viewModel.text
                }
            
            cell.priceTextField.rx.text.orEmpty
                .subscribe(onNext: { [unowned self] text in
                    self.dataTrigger.onNext(DynamicEditProductViewModel.DataType.price(text))
                })
                .disposed(by: cell.disposeBag)
            
            cell.priceTextField.rx.controlEvent(UIControl.Event.editingDidEnd)
                .subscribe(onNext: { [unowned self] _ in
                    self.endEditTrigger.onNext(())
                })
                .disposed(by: cell.disposeBag)
            
            priceTextField = cell.priceTextField
            priceValidationLabel = cell.validationLabel
            
            return cell
        }
    }
}

// MARK: - StoryboardSceneBased
extension DynamicEditProductViewController: StoryboardSceneBased {
    static var sceneStoryboard = Storyboards.product
}

extension Container {
    func dynamicEditProduct(navigationController: UINavigationController, product: Product) -> Factory<DynamicEditProductViewController> {
        Factory(self) {
            let vc = DynamicEditProductViewController.instantiate()
            let vm = DynamicEditProductViewModel(navigationController: navigationController, product: product)
            vc.bindViewModel(to: vm)
            return vc
        }
    }
}
