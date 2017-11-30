//
//  UIAlertViewController+Rx.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 11/30/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift

extension UIViewController {
    func alert(title: String, text: String?) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: { (action) in
                observer.onCompleted()
            }))
            self.present(alert, animated: true, completion: nil)
            return Disposables.create { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
        })
    }
}
