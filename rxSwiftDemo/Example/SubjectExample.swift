//
//  SubjectExample.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 11/28/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import RxSwift

struct SubjectExample {
    static func running() {
        example(description: "PublishSubject") {
            let subject = PublishSubject<String>()
            subject.onNext("Is anyone listening?")
            let subscriptionOne = subject
                .subscribe(onNext: { (element) in
                    print(element)
                })
            subject.on(.next("1"))
            subject.on(.next("2"))
            
            let subscriptionTwo = subject
                .subscribe({ (event) in
                    print("2)", event.element ?? event)
                })
            subject.onNext("3")
            subscriptionOne.dispose()
            subject.onNext("4")
            
            // 1
            subject.onCompleted()
            // 2
            subject.onNext("5")
            // 3
            subscriptionTwo.dispose()
            let disposeBag = DisposeBag()
            // 4
            subject
                .subscribe {
                    print("3)", $0.element ?? $0)
                }
                .disposed(by: disposeBag)
            subject.onNext("?")
        }
        
        enum MyError: Error {
            case anError
        }
        example(description: "BehaviorSubject") {
            
            let subject = BehaviorSubject(value: "Initial value")
            let disposeBag = DisposeBag()
            subject
                .subscribe({ (event) in
                    print("1)", event.element ?? event.error ?? event)
                })
                .disposed(by: disposeBag)
            subject.onNext("X")
            subject.onError(MyError.anError)
            
            subject
                .subscribe({ (event) in
                    print("2)", event.element ?? event.error ?? event)
                })
                .disposed(by: disposeBag)
        }
        
        example(description: "ReplaySubject") {
            let subject = ReplaySubject<String>.create(bufferSize: 2)
            let disposeBag = DisposeBag()
            subject.onNext("1")
            subject.onNext("2")
            subject.onNext("3")
            
            subject
                .subscribe({ (event) in
                    print("1)", event.element ?? event.error ?? event)
                })
                .disposed(by: disposeBag)
            
            subject
                .subscribe({ (event) in
                    print("2)", event.element ?? event.error ?? event)
                })
                .disposed(by: disposeBag)
            
            subject.onNext("4")
            subject
                .subscribe({ (event) in
                    print("3)", event.element ?? event.error ?? event)
                })
                .disposed(by: disposeBag)
            
            subject.onError(MyError.anError)
            subject.dispose()
        }
        
        example(description: "Variable") {
            let variable = Variable<String>("Initial value")
            let disposeBag = DisposeBag()
            variable.value = "New initial value"
            variable.asObservable()
                .subscribe({ (event) in
                    print("1)", event.element ?? event.error ?? event)
                })
                .disposed(by: disposeBag)
            
            variable.value = "1"
            
            variable.asObservable()
                .subscribe({ (event) in
                    print("2)", event.element ?? event.error ?? event)
                })
                .disposed(by: disposeBag)
            
            variable.value = "2"
        }
        
        example(description: "PublishSubject") {
            
            let disposeBag = DisposeBag()
            
            let dealtHand = PublishSubject<[(String, Int)]>()
            
            func deal(_ cardCount: UInt) {
                var deck = cards
                var cardsRemaining: UInt32 = 52
                var hand = [(String, Int)]()
                
                for _ in 0..<cardCount {
                    let randomIndex = Int(arc4random_uniform(cardsRemaining))
                    hand.append(deck[randomIndex])
                    deck.remove(at: randomIndex)
                    cardsRemaining -= 1
                }
                
                // Add code to update dealtHand here
                if points(for: hand) > 21 {
                    dealtHand.onError(HandError.busted)
                } else {
                    dealtHand.onNext(hand)
                }
            }
            
            // Add subscription to dealtHand here
            dealtHand
                .subscribe(onNext: { (element) in
                    print("Card string", cardString(for: element))
                    print("Point", points(for: element))
                }, onError: { (error) in
                    print("Error")
                })
                .disposed(by: disposeBag)
            
            deal(3)
        }
        
    }
}
