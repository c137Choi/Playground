import Foundation
import RxSwift

extension ObservableType {
    
    func flatMapLatest<T>(_ handler: @escaping (Element) async throws -> T) -> RxObservable<T> {
        flatMapLatest { element in
            RxObservable.async {
                try await handler(element)
            }
        }
    }
    
    func flatMapFirst<T>(_ handler: @escaping (Element) async throws -> T) -> RxObservable<T> {
        flatMapFirst { element in
            RxObservable.async {
                try await handler(element)
            }
        }
    }
    
    func flatMap<T>(_ handler: @escaping (Element) async throws -> T) -> RxObservable<T> {
        flatMap { element in
            RxObservable.async {
                try await handler(element)
            }
        }
    }
    
    func concatMap<T>(_ handler: @escaping (Element) async throws -> T) -> RxObservable<T> {
        concatMap { element in
            RxObservable.async {
                try await handler(element)
            }
        }
    }
    
    static func async(_ handler: @escaping () async throws -> Element) -> RxObservable<Element> {
        RxObservable<Element>.create { observer in
            let task = Task {
                do {
                    let result = try await handler()
                    observer.onNext(result)
                    observer.onCompleted()
                } catch {
                    observer.on(.error(error))
                }
            }
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
