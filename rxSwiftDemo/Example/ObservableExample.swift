//
//  ObservableExample.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 11/28/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import RxSwift

struct ObservableExample {
    
    
    static func running() {
        example(description: "just, of, from") {
            let one = 1
            let two = 2
            let three = 3
            
            let observable = Observable<Int>.just(one)
            let observable2 = Observable<Int>.of(one, two, three)
            let observable3 = Observable<Int>.from([one, two, three])
            
            observable2.subscribe({ (event) in
                print(event)
            })
            
            observable3.subscribe(onNext: { (value) in
                print(value)
            })
        }
        
        example(description: "empty") {
            let observable = Observable<Void>.empty()
            observable.subscribe(onNext: { (element) in
                print(element)
            }, onCompleted: {
                print("completed")
            })
        }
        
        example(description: "never") {
            let dispose = DisposeBag()
            let observable = Observable<Int>.never()
            observable
                .debug("com.baon", trimOutput: false)
                .do(onSubscribe: {
                    print("onSubscribe")
                }, onSubscribed: {
                    print("onSubscribed")
                })
                .subscribe(onNext: {
                    print($0)
                }, onCompleted: {
                    print("completed")
                })
                .disposed(by: dispose)
        }
        
        example(description: "range") {
            let observable = Observable<Int>.range(start: 1, count: 20)
            observable
                .subscribe(onNext: { (element) in
                    print(element)
                }, onCompleted: {
                    print("completed")
                })
        }
        
        example(description: "dispose") {
            let dispose = DisposeBag()
            Observable
                .of("A", "B", "C")
                .subscribe {
                    print($0)
                }
                .disposed(by: dispose)
            
        }
        
        example(description: "create") {
            let dispose = DisposeBag()
            Observable<String>.create({ (observer) -> Disposable in
                observer.onNext("1")
                observer.onCompleted()
                observer.onNext("2")
                return Disposables.create()
            })
                .subscribe(onNext: { (element) in
                    print(element)
                }, onCompleted: {
                    print("Completed")
                }, onDisposed: {
                    print("Disposed")
                })
                .disposed(by: dispose)
        }
        
        example(description: "defered") {
            var flip = false
            let dispose = DisposeBag()
            let factory = Observable<Int>.deferred({ () -> Observable<Int> in
                flip = !flip
                if flip {
                    return Observable<Int>.of(1, 2, 3)
                }
                return Observable<Int>.of(4, 5, 6)
            })
            
            for _ in 0...3 {
                factory
                    .subscribe(onNext: { (element) in
                        print(element, terminator: "")
                    })
                    .disposed(by: dispose)
                print()
            }
        }
    }
}
