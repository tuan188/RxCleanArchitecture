import Foundation
import CoreStore
import RxSwift

public protocol CoreDataMappable {
    associatedtype Entity
    
    // Initializes a model from a CoreData entity
    init?(entity: Entity)
    
    // Maps the model data to a CoreData entity
    func map(to entity: Entity)
}

public protocol CoreDataRepository {
    associatedtype Model: CoreDataMappable
    associatedtype Entity: NSManagedObject
    
    // CoreStore DataStack to manage CoreData transactions
    var dataStack: DataStack { get }
}

public extension CoreDataRepository where Entity == Model.Entity {
    
    /// Creates multiple CoreData entities from models
    /// - Parameters:
    ///   - objects: An array of models to be mapped to CoreData entities
    ///   - action: A closure to map each model to its corresponding entity
    /// - Returns: An Observable that completes when all entities are created or emits an error if something fails
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
    
    /// Creates a CoreData entity and applies a custom action to it
    /// - Parameter action: A closure to configure the newly created entity
    /// - Returns: An Observable that completes when the entity is created or emits an error if the operation fails
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
    
    /// Fetches a single CoreData entity and maps it to a model
    /// - Parameter clauses: Fetch clauses to specify search conditions
    /// - Returns: An Observable that emits the fetched model or nil if no entity is found
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
    
    /// Fetches a single CoreData entity and maps it to a model (non-reactive version)
    /// - Parameter clauses: Fetch clauses to specify search conditions
    /// - Throws: An error if fetching fails
    /// - Returns: The fetched model or nil if no entity is found
    func fetchOne(clauses: FetchClause...) throws -> Model? {
        guard let entity = try dataStack.fetchOne(From<Entity>(), clauses) else { return nil }
        return Model(entity: entity)
    }
    
    /// Fetches all CoreData entities that match the clauses and maps them to models
    /// - Parameter clauses: Fetch clauses to specify search conditions
    /// - Returns: An Observable that emits an array of models or an error if fetching fails
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
    
    /// Fetches all CoreData entities that match the clauses and maps them to models (non-reactive version)
    /// - Parameter clauses: Fetch clauses to specify search conditions
    /// - Throws: An error if fetching fails
    /// - Returns: An array of models representing the fetched entities
    func fetchAll(clauses: FetchClause...) throws -> [Model] {
        let entities = try dataStack.fetchAll(From<Entity>(), clauses)
        return entities.compactMap { Model(entity: $0) }
    }
    
    /// Counts CoreData entities that match the clauses
    /// - Parameter clauses: Fetch clauses to specify search conditions
    /// - Returns: An Observable that emits the count of matching entities or an error if the operation fails
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
    
    /// Counts CoreData entities that match the clauses (non-reactive version)
    /// - Parameter clauses: Fetch clauses to specify search conditions
    /// - Throws: An error if counting fails
    /// - Returns: The count of matching entities
    func fetchCount(clauses: FetchClause...) throws -> Int {
        try dataStack.fetchCount(From<Entity>(), clauses)
    }
    
    /// Deletes a single CoreData entity that matches the clauses
    /// - Parameter clauses: Fetch clauses to specify search conditions
    /// - Returns: An Observable that completes when deletion is successful or emits an error if deletion fails
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
    
    /// Deletes all CoreData entities that match the clauses
    /// - Parameter clauses: Delete clauses to specify search conditions
    /// - Returns: An Observable that completes when all matching entities are deleted or emits an error if deletion fails
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
    
    /// Updates a single CoreData entity with the provided model data
    /// - Parameters:
    ///   - object: The model data to be mapped to the entity
    ///   - clauses: Fetch clauses to specify search conditions for the entity to update
    ///   - action: A closure to map the model to the entity
    /// - Returns: An Observable that completes when the update is successful or emits an error if it fails
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
    
    /// Updates multiple CoreData entities with provided model data
    /// - Parameters:
    ///   - objects: Array of models to be mapped to their corresponding entities
    ///   - clauses: A closure that returns fetch clauses for each model to find the corresponding entity
    ///   - action: A closure to map each model to its entity
    /// - Returns: An Observable that completes when all updates are successful or emits an error if any update fails
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
    
    /// Updates a single CoreData entity found by fetch clauses with custom actions
    /// - Parameters:
    ///   - clauses: Fetch clauses to locate the entity to be updated
    ///   - action: A closure to perform the update on the entity
    /// - Returns: An Observable that completes when the update is successful or emits an error if it fails
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
    
    /// Updates all CoreData entities found by fetch clauses with a custom action
    /// - Parameters:
    ///   - clauses: Fetch clauses to locate entities to update
    ///   - action: A closure to perform the update on each entity
    /// - Returns: An Observable that completes when all updates are successful or emits an error if any update fails
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
