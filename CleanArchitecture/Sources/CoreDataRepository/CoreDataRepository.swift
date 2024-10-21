//
//  CoreDataRepository.swift
//  CleanArchitecture
//
//  Created by truong.anh.tuan on 21/10/24.
//  Copyright © 2024 Sun Asterisk. All rights reserved.
//

import Foundation
import CoreStore
import RxSwift

public protocol CoreDataMappable {
    associatedtype Entity
    
    init?(entity: Entity)
    func map(to entity: Entity)
}

public protocol CoreDataRepository {
    associatedtype Model: CoreDataMappable
    associatedtype Entity: NSManagedObject
    
    var dataStack: DataStack { get }
}

public extension CoreDataRepository where Entity == Model.Entity {
    func create(objects: [Model],
                action: @escaping (Model, Entity) -> Void = { $0.map(to: $1) }) -> Observable<Void> {
        Observable<Void>.create { observer in
            var trans: AsynchronousDataTransaction?
            
            dataStack.perform { transaction in
                trans = transaction
                
                for object in objects {
                    let entity = transaction.create(Into<Entity>())
                    action(object, entity)
                }
            } completion: { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                _ = try? trans?.cancel()
            }
        }
    }
    
    func create(action: @escaping (Entity) -> Void) -> Observable<Void> {
        Observable<Void>.create { observer in
            var trans: AsynchronousDataTransaction?
            
            dataStack.perform { transaction in
                trans = transaction
                let entity = transaction.create(Into<Entity>())
                action(entity)
            } completion: { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                _ = try? trans?.cancel()
            }
        }
    }
    
    func fetchOne(clauses: FetchClause...) -> Observable<Model?> {
        Observable<Model?>.create { observer in
            var trans: AsynchronousDataTransaction?
            
            dataStack.perform { transaction -> Model? in
                trans = transaction
                guard let entity = try transaction.fetchOne(From<Entity>(), clauses) else { return nil }
                return Model(entity: entity)
            } completion: { result in
                switch result {
                case .success(let entity):
                    observer.onNext(entity)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                _ = try? trans?.cancel()
            }
        }
    }
    
    func fetchOne(clauses: FetchClause...) throws -> Model? {
        guard let entity = try dataStack.fetchOne(From<Entity>(), clauses) else { return nil }
        return Model(entity: entity)
    }
    
    func fetchAll(clauses: FetchClause...) -> Observable<[Model]> {
        Observable<[Model]>.create { observer in
            var trans: AsynchronousDataTransaction?
            
            dataStack.perform { transaction -> [Model] in
                trans = transaction
                let entities = try transaction.fetchAll(From<Entity>(), clauses)
                return entities.compactMap { Model(entity: $0) }
            } completion: { result in
                switch result {
                case .success(let entities):
                    observer.onNext(entities)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                _ = try? trans?.cancel()
            }
        }
    }
    
    func fetchAll(clauses: FetchClause...) throws -> [Model] {
        let entities = try dataStack.fetchAll(From<Entity>(), clauses)
        return entities.compactMap { Model(entity: $0) }
    }
    
    func fetchCount(clauses: FetchClause...) -> Observable<Int> {
        Observable<Int>.create { observer in
            var trans: AsynchronousDataTransaction?
            
            dataStack.perform { transaction -> Int in
                trans = transaction
                return try transaction.fetchCount(From<Entity>(), clauses)
            } completion: { result in
                switch result {
                case .success(let count):
                    observer.onNext(count)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                _ = try? trans?.cancel()
            }
        }
    }
    
    func fetchCount(clauses: FetchClause...) throws -> Int {
        try dataStack.fetchCount(From<Entity>(), clauses)
    }
    
    func delete(clauses: FetchClause...) -> Observable<Void> {
        Observable<Void>.create { observer in
            var trans: AsynchronousDataTransaction?
            
            dataStack.perform { transaction -> Void in
                trans = transaction
                let entity = try transaction.fetchOne(From<Entity>(), clauses)
                transaction.delete(entity)
            } completion: { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                _ = try? trans?.cancel()
            }
        }
    }
    
    func deleteAll(clauses: DeleteClause...) -> Observable<Void> {
        Observable<Void>.create { observer in
            var trans: AsynchronousDataTransaction?
            
            dataStack.perform { transaction -> Void in
                trans = transaction
                try transaction.deleteAll(From<Entity>(), clauses)
            } completion: { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                _ = try? trans?.cancel()
            }
        }
    }
    
    func update(object: Model,
                clauses: FetchClause...,
                action: @escaping (Model, Entity) -> Void = { $0.map(to: $1) }) -> Observable<Void> {
        Observable<Void>.create { observer in
            var trans: AsynchronousDataTransaction?
            
            dataStack.perform { transaction -> Void in
                trans = transaction
                guard let entity = try transaction.fetchOne(From<Entity>(), clauses) else { return }
                action(object, entity)
            } completion: { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                _ = try? trans?.cancel()
            }
        }
    }
    
    func updateAll(objects: [Model],
                   clauses: @escaping (Model) -> [FetchClause],
                   action: @escaping (Model, Entity) -> Void = { $0.map(to: $1) }) -> Observable<Void> {
        Observable<Void>.create { observer in
            var trans: AsynchronousDataTransaction?
            
            dataStack.perform { transaction -> Void in
                trans = transaction
                for object in objects {
                    guard let entity = try transaction.fetchOne(From<Entity>(), clauses(object)) else { return }
                    action(object, entity)
                }
            } completion: { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                _ = try? trans?.cancel()
            }
        }
    }
    
    func update(clauses: FetchClause..., action: @escaping (Entity) -> Void) -> Observable<Void> {
        Observable<Void>.create { observer in
            var trans: AsynchronousDataTransaction?
            
            dataStack.perform { transaction -> Void in
                trans = transaction
                guard let entity = try transaction.fetchOne(From<Entity>(), clauses) else { return }
                action(entity)
            } completion: { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                _ = try? trans?.cancel()
            }
        }
    }
    
    func updateAll(clauses: FetchClause..., action: @escaping (Entity) -> Void) -> Observable<Void> {
        Observable<Void>.create { observer in
            var trans: AsynchronousDataTransaction?
            
            dataStack.perform { transaction -> Void in
                trans = transaction
                let entities = try transaction.fetchAll(From<Entity>(), clauses)
                
                for entity in entities {
                    action(entity)
                }
            } completion: { result in
                switch result {
                case .success:
                    observer.onNext(())
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                _ = try? trans?.cancel()
            }
        }
    }
}
