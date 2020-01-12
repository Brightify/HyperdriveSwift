//
//  UINavigationController+RxNavigation.swift
//  RxReactant
//
//  Created by Tadeas Kriz on 8/17/18.
//  Copyright © 2018 Brightify. All rights reserved.
//


#if canImport(RxSwift)
import RxSwift

extension Reactive where Base: UINavigationController {

    public func push<C: UIViewController>(controller: Single<C>, animated: Bool = true) -> Completable {
        return controller
            .flatMapCompletable {
                self.base.push(controller: $0, animated: animated)
                return Completable.empty()
            }
    }

    public func replace<C: UIViewController>(with controller: Single<C>, animated: Bool = true) -> Maybe<UIViewController> {

        return controller
            .flatMapMaybe {
                self.base.replace(with: $0, animated: animated).map(Maybe.just) ?? Maybe.empty()
            }
    }

    public func popAllAndReplace<C: UIViewController>(with controller: Single<C>) -> Single<[UIViewController]> {
        return Single.deferred {
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = .moveIn
            transition.subtype = .fromLeft
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.base.view.layer.add(transition, forKey: nil)

            return self.replaceAll(with: controller, animated: false)
        }
    }

    public func replaceAll<C: UIViewController>(with controller: Single<C>, animated: Bool = true) -> Single<[UIViewController]> {
        return controller
            .map {
                self.base.replaceAll(with: $0, animated: animated)
            }
    }
}
#endif
