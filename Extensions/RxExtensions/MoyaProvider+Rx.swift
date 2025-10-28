//
//  MoyaProvider+Rx.swift
//
//  Created by Choi on 2022/8/9.
//

import Moya
import RxSwift
import RxCocoa

public extension Reactive where Base: MoyaProviderType {

    /// Designated request-making method.
    ///
    /// - Parameters:
    ///   - token: Entity, which provides specifications necessary for a `MoyaProvider`.
    ///   - callbackQueue: Callback queue. If nil - queue from provider initializer will be used.
    /// - Returns: Single response object.
    func requestV2(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> Single<Response> {
        Single.create { single in
            let cancellableToken = base.request(token, callbackQueue: callbackQueue, progress: nil) { result in
                switch result {
                case let .success(response):
                    single(.success(response))
                case let .failure(error):
                    single(.failure(error))
                }
            }
            return Disposables.create(with: cancellableToken.cancel)
        }
    }

    /// Designated request-making method with progress.
    func requestWithProgressV2(_ token: Base.Target, callbackQueue: DispatchQueue? = nil) -> RxObservable<ProgressResponse> {

        let progressBlock = AnyObserver<ProgressResponse>.onNext
        let response: RxObservable<ProgressResponse> = RxObservable.create { observer in
            let cancellableToken = base.request(token, callbackQueue: callbackQueue, progress: progressBlock(observer)) { result in
                switch result {
                case .success:
                    observer.onCompleted()
                case let .failure(error):
                    observer.onError(error)
                }
            }
            return Disposables.create(with: cancellableToken.cancel)
        }

        // Accumulate all progress and combine them when the result comes
        return response.scan(ProgressResponse()) { last, progress in
            let progressObject = progress.progressObject ?? last.progressObject
            let response = progress.response ?? last.response
            return ProgressResponse(progress: progressObject, response: response)
        }
    }
}
