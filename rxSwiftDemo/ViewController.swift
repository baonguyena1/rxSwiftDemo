//
//  ViewController.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 11/28/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        example(description: "range") {
            let observable = Observable<Int>.range(start: 1, count: 20)
            observable.subscribe(onNext: { (element) in
                print(element)
            }, onCompleted: {
                print("completed")
            })
        }
        
        example(description: "dispose") {
            let dispose = DisposeBag()
            Observable.of("A", "B", "C")
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
        
    }
}

