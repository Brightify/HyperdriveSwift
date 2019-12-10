//
//  Wireframe+RxSwift.swift
//  RxReactant
//
//  Created by Tadeas Kriz on 8/17/18.
//  Copyright © 2018 Brightify. All rights reserved.
//

import RxSwift
import RxCocoa

public extension Wireframe {
    /**
     * Method used for convenient creating **UIViewController** with Observable containing result value from the controller
     * Usage is very similar to the create<T> method, except now there are two closure parameters in create.
     * - returns: Tuple containg the requested **UIViewController** and Observable with the type of the result.
     */
    func create<T, U>(factory: (FutureControllerProvider<T>, AnyObserver<U>) -> T) -> (T, Observable<U>) {
        let futureControllerProvider = FutureControllerProvider<T>()
        let subject = PublishSubject<U>()
        let controller = factory(futureControllerProvider, subject.asObserver())
        futureControllerProvider.controller = controller
        return (controller, subject.takeUntil(controller.rx.deallocated))
    }

    func create<T, U>(factory: (FutureControllerProvider<T>, (SingleEvent<U>) -> Void) -> T) -> (T, Single<U>) {
        let futureControllerProvider = FutureControllerProvider<T>()
        let subject = PublishSubject<U>()
        let controller = factory(futureControllerProvider, { event in
            switch event {
            case .success(let value):
                subject.onLast(value)
            case .error(let error):
                subject.onError(error)
            }
        })
        futureControllerProvider.controller = controller
        return (controller, subject.take(1).takeUntil(controller.rx.deallocated).asSingle())
    }

    func create<T, U>(factory: (FutureControllerProvider<T>, (MaybeEvent<U>) -> Void) -> T) -> (T, Maybe<U>) {
        let futureControllerProvider = FutureControllerProvider<T>()
        let subject = PublishSubject<U>()
        let controller = factory(futureControllerProvider, { event in
            switch event {
            case .success(let value):
                subject.onLast(value)
            case .completed:
                subject.onCompleted()
            case .error(let error):
                subject.onError(error)
            }
        })
        futureControllerProvider.controller = controller
        return (controller, subject.take(1).takeUntil(controller.rx.deallocated).asMaybe())
    }

    func create<T>(factory: (FutureControllerProvider<T>, (CompletableEvent) -> Void) -> T) -> (T, Completable) {
        let futureControllerProvider = FutureControllerProvider<T>()
        let subject = PublishSubject<Never>()
        let controller = factory(futureControllerProvider, { event in
            switch event {
            case .completed:
                subject.onCompleted()
            case .error(let error):
                subject.onError(error)
            }
        })
        futureControllerProvider.controller = controller
        return (controller, subject.takeUntil(controller.rx.deallocated).asCompletable())
    }
}
