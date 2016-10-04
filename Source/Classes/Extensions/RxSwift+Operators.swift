//
//  RxSwift+Operators.swift
//
//  Created by Tadeas Kriz on 15/03/16.
//

import RxSwift

open extension ObserverType {
    /**
     Convenience method equivalent to `on(.Next(element: E))` and `on(.Completed)`

     - parameter element: Next element to send to observer(s)
     */
    open final func onLast(_ element: E) {
        on(.next(element))
        on(.completed)
    }
}

open extension ObservableConvertibleType {
    open func lag() -> Observable<(previous: E?, current: E)> {
        return asObservable().scan((previous: nil as E?, current: nil as E?)) {
            ($0.current, current: $1)
            }
            .filter { $0.current != nil }
            .map { ($0, $1!) }
    }

    open func rewrite<T>(with value: T) -> Observable<T> {
        return asObservable().map { _ in value }
    }

    open func withLatestFrom<O: ObservableConvertibleType>(right second: O) -> Observable<(E, O.E)> {
        return asObservable().withLatestFrom(second) { ($0, $1) }
    }

    open func withLatestFrom<O: ObservableConvertibleType>(left second: O) -> Observable<(O.E, E)> {
        return asObservable().withLatestFrom(second) { ($1, $0) }
    }

    open func with<T, U>(_ value: T, resultSelector: @escaping (E, T) -> U) -> Observable<U> {
        return asObservable().withLatestFrom(Observable.just(value), resultSelector: resultSelector)
    }

    open func with<T>(right value: T) -> Observable<(E, T)> {
        return asObservable().with(value) { ($0, $1) }
    }

    open func with<T>(left value: T) -> Observable<(T, E)> {
        return asObservable().with(value) { ($1, $0) }
    }

    open func nilOnError() -> Observable<E?> {
        return asObservable().map(Optional.init).catchErrorJustReturn(nil)
    }

    /// Similar to startWith, but does not resolve the value until it is subscribed to.
    open func startWithWhenSubscribed(source: () -> E) -> Observable<E> {
        return asObservable().map { value in { value } }.startWith(source).map { $0() }
    }
}

open func observe<T>(block: @escaping (AnyObserver<T>) -> Void) -> Observable<T> {
    return Observable<T>.create {
        block($0)
        return Disposables.create()
    }
}
