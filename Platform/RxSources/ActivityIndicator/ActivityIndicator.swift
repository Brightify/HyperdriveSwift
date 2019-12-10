//
//  ActivityIndicator.swift
//  Reactant
//
//  Created by Tadeáš Kříž on 09/09/16.
//  Copyright © 2016 Brightify. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

public final class ActivityIndicator<T>: ObservableConvertibleType {
    
    public typealias E = (loading: Bool, associatedValue: T?)
    
    public let disposeBag = DisposeBag()
    
    private let activeTrackings = BehaviorRelay<[(id: UUID, associatedValue: T?)]>(value: [])
    private let driver: Driver<E>
    private let equalFunction: (T?, T?) -> Bool
    fileprivate let defaultAssociatedValue: T?
    
    public init(defaultAssociatedValue: T? = nil, equalWhen equalFunction: @escaping (T, T) -> Bool) {
        self.defaultAssociatedValue = defaultAssociatedValue
        self.equalFunction = { lhs, rhs in
            if let lhs = lhs, let rhs = rhs {
                return equalFunction(lhs, rhs)
            } else {
                return lhs == nil && rhs == nil
            }
        }
        
        // `self` cannot be captured before all fields are initialized.
        let equal = self.equalFunction
        driver = activeTrackings.asDriver()
            .map { (loading: !$0.isEmpty, associatedValue: $0.compactMap { $0.associatedValue }.first) }
            .distinctUntilChanged { lhs, rhs in lhs.loading == rhs.loading &&
                equal(lhs.associatedValue, rhs.associatedValue) }
    }
    
    public func trackActivity<O: ObservableConvertibleType>(
        of source: O, initialAssociatedValue: T?,
        associatedValueProvider: @escaping (O.Element) -> T?
    ) -> Observable<O.Element> {
        // `self` is intentionally captured. It is released once the Observable is disposed.
        return Observable.create { subscriber in
            let observable = source.asObservable().share(replay: 1, scope: .forever)
            let subscriptionDisposable = observable.subscribe(subscriber)
            
            let id = UUID()
            
            let messageChangeDisposable = observable.map(associatedValueProvider)
                .startWith(initialAssociatedValue)
                .distinctUntilChanged(self.equalFunction)
                .subscribe(onNext: {
                    var activeTrackings = self.activeTrackings.value
                    if let index = activeTrackings.firstIndex(where: { $0.id == id }) {
                        activeTrackings[index].associatedValue = $0
                    } else {
                        activeTrackings.append((id: id, associatedValue: $0))
                    }
                    self.activeTrackings.accept(activeTrackings)
                })
            
            return Disposables.create {
                subscriptionDisposable.dispose()
                messageChangeDisposable.dispose()

                var activeTrackings = self.activeTrackings.value
                if let index = activeTrackings.firstIndex(where: { $0.id == id }) {
                    activeTrackings.remove(at: index)
                    self.activeTrackings.accept(activeTrackings)
                }
            }
        }
    }
    
    public func asObservable() -> Observable<E> {
        return driver.asObservable()
    }
    
    public func asDriver() -> Driver<E> {
        return driver
    }
}

extension ActivityIndicator where T: Equatable {
    
    public convenience init(defaultAssociatedValue: T? = nil) {
        self.init(defaultAssociatedValue: defaultAssociatedValue, equalWhen: ==)
    }
}

extension ActivityIndicator {
    
    func trackActivity<O: ObservableConvertibleType>(of source: O) -> Observable<O.Element> {
        return trackActivity(of: source, associatedValue: defaultAssociatedValue)
    }
    
    func trackActivity<O: ObservableConvertibleType>(of source: O, associatedValue: T?)
        -> Observable<O.Element> {
        return trackActivity(of: source, initialAssociatedValue: associatedValue,
                             associatedValueProvider: { _ in associatedValue })
    }
    
    func trackActivity<O: ObservableConvertibleType>(of source: O, associatedValueProvider: @escaping (O.Element) -> T?)
        -> Observable<O.Element> {
        return trackActivity(of: source, initialAssociatedValue: defaultAssociatedValue,
                             associatedValueProvider: associatedValueProvider)
    }
}

extension ObservableConvertibleType {
    
    func trackActivity<T>(in activityIndicator: ActivityIndicator<T>) -> Observable<Element> {
        return activityIndicator.trackActivity(of: self, associatedValue: activityIndicator.defaultAssociatedValue)
    }
    
    func trackActivity<T>(in activityIndicator: ActivityIndicator<T>, associatedValue: T?) -> Observable<Element> {
        return activityIndicator.trackActivity(of: self, associatedValue: associatedValue)
    }
    
    func trackActivity<T>(in activityIndicator: ActivityIndicator<T>, associatedValueProvider: @escaping (Element) -> T?)
        -> Observable<Element> {
        return activityIndicator.trackActivity(of: self, initialAssociatedValue: activityIndicator.defaultAssociatedValue,
                                               associatedValueProvider: associatedValueProvider)
    }
    
    func trackActivity<T>(in activityIndicator: ActivityIndicator<T>, initialAssociatedValue: T?,
                              associatedValueProvider: @escaping (Element) -> T?) -> Observable<Element> {
        return activityIndicator.trackActivity(of: self, initialAssociatedValue: initialAssociatedValue,
                                               associatedValueProvider: associatedValueProvider)
    }
}


