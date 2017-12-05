//
//  CombiningOperators.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 12/5/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift

struct CombiningOperator {
    static func running() {
        example(description: "startWith") {
            let disposeBag = DisposeBag()
            let numbers = Observable.of(2, 3, 4)
            let observable = numbers.startWith(1)
            observable.subscribe(onNext: {
                print($0)
            })
            .disposed(by: disposeBag)
        }
        
        example(description: "concat") {
            let disposeBag = DisposeBag()
            let first = Observable.of(1, 2, 3)
            let second = Observable.of(4, 5, 6)
            let observable = Observable.concat([first, second])
            observable
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        example(description: "merge") {
            let disposebag = DisposeBag()
            let left = PublishSubject<String>()
            let right = PublishSubject<String>()
            let source = Observable.of(left, right)
            let observable = source.merge()
            observable
                .subscribe(onNext:  {
                    print($0)
                })
                .disposed(by: disposebag)
            var leftValues = ["Berlin", "Munich", "Frankfurt"]
            var rightValues = ["Madrid", "Barcelona", "Valencia"]
            repeat {
                if arc4random_uniform(2) == 0 {
                    if !leftValues.isEmpty {
                        left.onNext("Left: " + leftValues.removeFirst())
                    }
                } else if !rightValues.isEmpty {
                    right.onNext("Right: " + rightValues.removeFirst())
                }
            } while !leftValues.isEmpty || !rightValues.isEmpty
        }
        
        example(description: "combineLatest") {
            let disposeBag = DisposeBag()
            let left = PublishSubject<String>()
            let right = PublishSubject<String>()
            let observable = Observable.combineLatest(left, right, resultSelector: { (lastLeft, lastRight) in
                "\(lastLeft) \(lastRight)"
            })
            observable
                .subscribe(onNext: { value in
                    print(value)
                })
                .disposed(by: disposeBag)
            
            print("> Sending a value to Left")
            left.onNext("Hello,")
            print("> Sending a value to Right")
            right.onNext("world")
            print("> Sending another value to Right")
            right.onNext("RxSwift")
            print("> Sending another value to Left")
            left.onNext("Have a good day,")
        }
        
        example(description: "combine user choice and value") {
            let disposeBag = DisposeBag()
            let choice: Observable<DateFormatter.Style> = Observable.of(.short, .long)
            let dates = Observable.of(Date())
            let observable = Observable.combineLatest(choice, dates, resultSelector: { (format, when) -> String in
                
                let formatter = DateFormatter()
                formatter.dateStyle = format
                return formatter.string(from: when)
            })
            
            observable.subscribe(onNext: { (value) in
                print(value)
            })
            .disposed(by: disposeBag)
            
        }
        
        example(description: "zip") {
            enum Weather {
                case cloudy
                case sunny
            }
            let bag = DisposeBag()
            let left: Observable<Weather> = Observable.of(.sunny, .cloudy, .cloudy, .sunny)
            let right = Observable.of("Lisbon", "Cophenhagen", "London", "Madrid", "Vienna")
            Observable
                .zip(left, right, resultSelector: { (weather, city) -> String in
                    return "It's \(weather) in \(city)"
                }).subscribe(onNext: { (value) in
                    print(value)
                })
                .disposed(by: bag)
        }
        
        example(description: "withLatestFrom") {
            let bag = DisposeBag()
            let button = PublishSubject<Void>()
            let textField = PublishSubject<String>()
            
//            let observable = textField.sample(button)
            let observable = button.withLatestFrom(textField)
            observable
                .subscribe(onNext: { (value) in
                    print(value)
                })
                .disposed(by: bag)
            
            // 3
            textField.onNext("Par")
            textField.onNext("Pari")
            textField.onNext("Paris")
            button.onNext(())
            button.onNext(())
        }
        
        example(description: "amb") {
            let bag = DisposeBag()
            let left = PublishSubject<String>()
            let right = PublishSubject<String>()
            
            let observable = left.amb(right)
            observable
                .subscribe(onNext: { (value) in
                    print(value)
                })
                .disposed(by: bag)
            
            right.onNext("Copenhagen")
            left.onNext("Lisbon")
            left.onNext("London")
            left.onNext("Madrid")
            right.onNext("Vienna")
        }
        
        example(description: "switchLatest") {
            let bag = DisposeBag()
            let one = PublishSubject<String>()
            let two = PublishSubject<String>()
            let three = PublishSubject<String>()
            let source = PublishSubject<Observable<String>>()
            
            let observable = source.switchLatest()
            observable
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: bag)
            
            // 3
            source.onNext(one)
            one.onNext("Some text from sequence one")
            two.onNext("Some text from sequence two")
            source.onNext(two)
            two.onNext("More text from sequence two")
            one.onNext("and also from sequence one")
            source.onNext(three)
            two.onNext("Why don't you seem me?")
            one.onNext("I'm alone, help me")
            three.onNext("Hey it's three. I win.")
            source.onNext(one)
            one.onNext("Nope. It's me, one!")
        }
        
        example(description: "reduce") {
            let bag = DisposeBag()
            let source = Observable.of(1, 3, 4, 7, 9)
            
            source
                .reduce(0, accumulator: +)
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: bag)
        }
        
        example(description: "scan") {
            let bag = DisposeBag()
            let source = Observable.of(1, 3, 5, 7, 9)
            source
                .scan(0, accumulator: +)
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: bag)
        }
        
    }
}
