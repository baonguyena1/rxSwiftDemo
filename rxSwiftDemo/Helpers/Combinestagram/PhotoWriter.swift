//
//  PhotoWriter.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 11/30/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift

class PhotoWriter: NSObject {
    typealias Callback = (Error?)->Void
    
    private var callback:Callback
    
    private init(callback: @escaping Callback) {
        self.callback = callback
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        callback(error)
    }
    
    static func save(_ image: UIImage) -> Observable<Void> {
        return Observable.create({ (observer) -> Disposable in
            
            let writer = PhotoWriter(callback: { (error) in
                if let error = error {
                    observer.onError(error)
                } else {
                    observer.onCompleted()
                }
            })
            
            UIImageWriteToSavedPhotosAlbum(image, writer, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            
            return Disposables.create()
        })
    }
}
