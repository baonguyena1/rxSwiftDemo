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
        
        // Challenge
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
        
        example(description: "Variable") {
            
            enum UserSession {
                
                case loggedIn, loggedOut
            }
            
            enum LoginError: Error {
                
                case invalidCredentials
            }
            
            let disposeBag = DisposeBag()
            
            // Create userSession Variable of type UserSession with initial value of .loggedOut
            let userSession = Variable<UserSession>(.loggedOut)
            
            // Subscribe to receive next events from userSession
            userSession.asObservable()
                .subscribe(onNext: { (userSession) in
                    print("userSession changed:", userSession)
                })
                .disposed(by: disposeBag)
            
            func logInWith(username: String, password: String, completion: (Error?) -> Void) {
                guard username == "johnny@appleseed.com",
                    password == "appleseed"
                    else {
                        completion(LoginError.invalidCredentials)
                        return
                }
                
                // Update userSession
                userSession.value = .loggedIn
            }
            
            func logOut() {
                // Update userSession
                userSession.value = .loggedOut
            }
            
            func performActionRequiringLoggedInUser(_ action: () -> Void) {
                // Ensure that userSession is loggedIn and then execute action()
                guard userSession.value == .loggedIn else {
                    print("you can't do that")
                    return
                }
                action()
            }
            
            for i in 1...2 {
                let password = i % 2 == 0 ? "appleseed" : "password"
                
                logInWith(username: "johnny@appleseed.com", password: password) { error in
                    guard error == nil else {
                        print(error!)
                        return
                    }
                    
                    print("User logged in.")
                }
                
                performActionRequiringLoggedInUser {
                    print("Successfully did something only a logged in user can do.")
                }
            }
        }
        
    }
}
