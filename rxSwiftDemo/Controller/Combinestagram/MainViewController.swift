//
//  MainViewController.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 11/30/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift

class MainViewController: UIViewController {

    @IBOutlet weak var imagePreview: UIImageView!
    @IBOutlet weak var buttonClear: UIButton!
    @IBOutlet weak var buttonSave: UIButton!
    @IBOutlet weak var itemAdd: UIBarButtonItem!
    
    fileprivate let bag = DisposeBag()
    fileprivate let images = Variable<[UIImage]>([])
    fileprivate var imageCache = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        images.asObservable()
            .throttle(0.5, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (photos) in
                guard let preview = self?.imagePreview else { return }
                preview.image = UIImage.collage(images: photos, size: preview.frame.size)
            })
            .disposed(by: bag)
        
        images.asObservable()
            .subscribe(onNext: { [weak self] photos in
                self?.updateUI(photos: photos)
            })
            .disposed(by: bag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func actionClear() {
        images.value = []
        imageCache = []
        navigationItem.leftBarButtonItem = nil
    }
    
    @IBAction func actionSave() {
        guard let image = self.imagePreview.image else {
            return
        }
        
        PhotoWriter.save(image)
            .subscribe(onError: { [weak self] (error) in
                self?.showMessage("Error", description: error.localizedDescription)
            }) {[weak self] in
                self?.showMessage("Saved")
                self?.actionClear()
            }
            .disposed(by: bag)
    }
    
    @IBAction func actionAdd() {
        let photosViewController = UIStoryboard(name: "Combinestagram", bundle: nil).instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        let newPhotos = photosViewController.selectedPhotos.share()
        
        newPhotos
            .takeWhile { [weak self] image in
                return (self?.images.value.count ?? 0) < 6
            }
            .filter { newImage in
                return newImage.size.width > newImage.size.height
            }
            .filter { [weak self] newImage in
                let len = UIImagePNGRepresentation(newImage)?.count ?? 0
                guard self?.imageCache.contains(len) == false else {
                    return false
                }
                self?.imageCache.append(len)
                return true
            }
            .subscribe(onNext: { [weak self] newImage in
                guard let images = self?.images else { return }
                images.value.append(newImage)
                }, onDisposed: {
                    print("completed photo selection")
            })
            .disposed(by: photosViewController.bag)
        
        newPhotos
            .ignoreElements()
            .subscribe(onCompleted: { [weak self] in
                self?.updateNavigationIcon()
            })
            .disposed(by: photosViewController.bag)
        
        navigationController!.pushViewController(photosViewController, animated: true)
    }
    
    fileprivate func updateNavigationIcon() {
        let icon = imagePreview.image?
            .scaled(CGSize(width: 22, height: 22))
            .withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon,
                                                           style: .done, target: nil, action: nil)
    }
    
    func showMessage(_ title: String, description: String? = nil) {
        alert(title: title, text: description)
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: bag)
    }
    
    fileprivate func updateUI(photos: [UIImage]) {
        buttonSave.isEnabled = photos.count > 0 && photos.count % 2 == 0
        buttonClear.isEnabled = photos.count > 0
        itemAdd.isEnabled = photos.count < 6
        self.title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
    }

}
