//
//  PHPhotoLibrary+rx.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 12/1/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import Foundation
import Photos
import RxSwift

extension PHPhotoLibrary {
    static var authorized: Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            
            DispatchQueue.main.async {
                if authorizationStatus() == .authorized {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    requestAuthorization({ (newStatus) in
                        observer.onNext(newStatus == .authorized)
                        observer.onCompleted()
                    })
                }
            }
            
            return Disposables.create()
        })
    }
}
