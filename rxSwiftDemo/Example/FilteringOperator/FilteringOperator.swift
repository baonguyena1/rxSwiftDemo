//
//  FilteringOperator.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 11/30/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift

struct FilteringOperator {
    static func runnning() {
        example(description: "ignoreElements") {
            let disposeBag = DisposeBag()
            let strikes = PublishSubject<String>()
            strikes
                .ignoreElements()
                .subscribe { _ in
                    print("You're out!")
                }
                .disposed(by: disposeBag)
            strikes.onNext("x")
            strikes.onNext("x")
            strikes.onNext("x")
            strikes.onCompleted()
        }
        
        example(description: "elementAt") {
            let disposeBag = DisposeBag()
            let strikes = PublishSubject<String>()
            strikes
                .elementAt(1)
                .subscribe(onNext: { (element) in
                    print(element)
                })
                .disposed(by: disposeBag)
            strikes.onNext("1")
            strikes.onNext("2")
            strikes.onNext("3")
        }
        
        example(description: "filter") {
            let disposeBag = DisposeBag()
            Observable.of(1, 2, 3, 4, 5, 6)
                .filter({ (element) -> Bool in
                    return element % 2 == 0
                })
                .subscribe(onNext: { (element) in
                    print(element)
                })
                .disposed(by: disposeBag)
        }
    
    }
}
