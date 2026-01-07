import Foundation
import RxSwift

extension PrimitiveSequenceType where Trait == CompletableTrait, Element == Swift.Never {
    
    static func async(_ handler: @escaping () async throws -> Void) -> Completable {
        Completable.create { completable in
            let task = Task {
                do {
                    try await handler()
                    completable(.completed)
                } catch {
                    completable(.error(error))
                }
            }
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
