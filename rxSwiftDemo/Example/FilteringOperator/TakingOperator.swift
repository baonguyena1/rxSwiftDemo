//
//  TakingOperator.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 11/30/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift

struct TakingOperator {
    static func running() {
        // Taking is the opposite of skipping
        example(description: "take") {
            let disposeBag = DisposeBag()
            Observable.of(1,2,3,4,5,6,7)
                .take(3)
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        example(description: "takeWhiteWithIndex") {
            let disposeBag = DisposeBag()
            Observable.of(2, 2, 4, 4, 5, 6, 7, 8, 9)
                .takeWhile({ (element) -> Bool in
                    element % 2 == 0
                })
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        example(description: "takeUtil") {
            let disposeBag = DisposeBag()
            let subject = PublishSubject<String>()
            let trigger = PublishSubject<String>()
            subject
                .takeUntil(trigger)
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
            subject.onNext("1")
            subject.onNext("2")
            trigger.onNext("X")
            subject.onNext("3")
        }
        
        example(description: "distinctUtilChanged") {
            let disposeBag = DisposeBag()
            Observable.of("A", "B", "B", "C", "C", "A")
                .distinctUntilChanged()
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        example(description: "distinctUtilChanged(_:)") {
            let disposeBag = DisposeBag()
            Observable.of("A", "B", "b", "C", "c", "A")
                .distinctUntilChanged({ (first, second) -> Bool in
                    first.lowercased() == second.lowercased()
                })
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        example(description: "distinctUntilChanged(_:)") {
            let disposeBag = DisposeBag()
            // 1
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            // 2
            Observable<NSNumber>.of(10, 110, 20, 200, 210, 310)
                // 3
                .distinctUntilChanged { a, b in
                    // 4
                    guard let aWords = formatter.string(from:
                        a)?.components(separatedBy: " "),
                        let bWords = formatter.string(from: b)?.components(separatedBy: " ")
                            else {
                            return false
                    }
                    var containsMatch = false
                    for aWord in aWords {
                        for bWord in bWords {
                            if aWord == bWord {
                                containsMatch = true
                                break
                            } }
                    }
                    return containsMatch
                }
                // 4
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by:disposeBag)
        }
    }
}
