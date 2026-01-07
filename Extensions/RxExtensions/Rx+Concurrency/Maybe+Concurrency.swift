import Foundation
import RxSwift

extension PrimitiveSequenceType where Trait == MaybeTrait {
    
    static func async(_ handler: @escaping () async throws -> Element?) -> Maybe<Element> {
        Maybe.create { maybe in
            let task = Task {
                do {
                    if let value = try await handler() {
                        maybe(.success(value))
                        return
                    }
                    maybe(.completed)
                } catch {
                    maybe(.error(error))
                }
            }
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
