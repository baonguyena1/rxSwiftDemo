//
//  SkippingOperator.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 11/30/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift

struct SkippingOperator {
    static func running() {
        example(description: "skip") {
            let disposeBag = DisposeBag()
            Observable.of("a", "b", "c", "d", "e", "f")
                .skip(3)
                .subscribe(onNext: { (element) in
                    print(element)
                })
                .disposed(by: disposeBag)
        }
        
        example(description: "skipWhile") {
            let disposeBag = DisposeBag()
            Observable.of(2, 2, 3, 4, 4)
                .skipWhile {
                    $0 % 2 == 0
                }
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        example(description: "skipUtil") {
            let disposeBag = DisposeBag()
            let subject = PublishSubject<String>()
            let trigger = PublishSubject<String>()
            
            subject
                .skipUntil(trigger)
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            
            subject.onNext("A")
            subject.onNext("B")
            trigger.onNext("X")
            subject.onNext("C")
        }
    }
}
