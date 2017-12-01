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
        }
    }
}
