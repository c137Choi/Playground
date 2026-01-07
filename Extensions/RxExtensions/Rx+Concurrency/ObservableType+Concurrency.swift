import Foundation
import RxSwift

extension ObservableType {
    
    func flatMapLatest<T>(_ handler: @escaping (Element) async throws -> T) -> Observable<T> {
        flatMapLatest { element in
            Observable.async {
                try await handler(element)
            }
        }
    }
    
    func flatMapFirst<T>(_ handler: @escaping (Element) async throws -> T) -> Observable<T> {
        flatMapFirst { element in
            Observable.async {
                try await handler(element)
            }
        }
    }
    
    func flatMap<T>(_ handler: @escaping (Element) async throws -> T) -> Observable<T> {
        flatMap { element in
            Observable.async {
                try await handler(element)
            }
        }
    }
    
    func concatMap<T>(_ handler: @escaping (Element) async throws -> T) -> Observable<T> {
        concatMap { element in
            Observable.async {
                try await handler(element)
            }
        }
    }
    
    static func async(_ handler: @escaping () async throws -> Element) -> Observable<Element> {
        Observable<Element>.create { observer in
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
