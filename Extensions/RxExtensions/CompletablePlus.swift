//
//  CompletablePlus.swift
//  RxPlayground
//
//  Created by Choi on 2022/4/20.
//

import RxSwift

extension Completable {
    
    static var empty: Completable {
        .empty()
    }
    
    func andThen(_ completableBuilder: () -> Completable) -> Completable {
        andThen(completableBuilder())
    }
    
    func concatMap<Source: ObservableConvertibleType>(_ selector: () throws -> Source)
    -> RxObservable<Source.Element> {
        do {
            let next = try selector().asObservable()
            return andThen(next)
        } catch {
            return .error(error)
        }
    }
}

extension Completable {
    /// 串联Completable
    static func +(lhs: Completable, rhs: Completable) -> Completable {
        lhs.andThen(rhs)
    }
}
