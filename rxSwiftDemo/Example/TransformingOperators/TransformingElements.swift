//
//  TransformingElements.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 12/1/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift

struct TransformingElements {
    
    static func running() {
        example(description: "toArray") {
            let disposeBag = DisposeBag()
            Observable.of("A", "B", "C")
                .toArray()
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        example(description: "map") {
            let disposeBag = DisposeBag()
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            Observable<NSNumber>.of(123, 4, 56)
                .map {
                    formatter.string(from: $0) ?? ""
                }
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposeBag)
        }
        
        struct Student {
            var score: Variable<Int>
        }
        
        example(description: "flatMap") {
            let disposebag = DisposeBag()
            
            let ryan = Student(score: Variable(80))
            let charlotte = Student(score: Variable(90))
            
            let student = PublishSubject<Student>()
            student.asObserver()
                .flatMap {
                    $0.score.asObservable()
                }
                .subscribe(onNext: {
                    print($0)
                })
            .disposed(by: disposebag)
            
            student.onNext(ryan)
            ryan.score.value = 10
            student.onNext(charlotte)
            ryan.score.value = 10
            charlotte.score.value = 50
        }
        
        example(description: "flatMapLatest") {
            let disposebag = DisposeBag()
            
            let ryan = Student(score: Variable(80))
            let charlotte = Student(score: Variable(90))
            
            let student = PublishSubject<Student>()
            student.asObserver()
                .flatMapLatest {
                    $0.score.asObservable()
                }
                .subscribe(onNext: {
                    print($0)
                })
                .disposed(by: disposebag)
            
            student.onNext(ryan)
            ryan.score.value = 10
            student.onNext(charlotte)
            ryan.score.value = 10
            charlotte.score.value = 50
        }
    }
}
