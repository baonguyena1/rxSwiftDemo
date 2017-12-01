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
            .subscribe(onNext: { [weak self] (photos) in
                self?.updateUI(photos: photos)
                guard let preview = self?.imagePreview else { return }
                preview.image = UIImage.collage(images: photos, size: preview.frame.size)
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
        let photoViewsController = UIStoryboard(name: "Combinestagram", bundle: nil).instantiateViewController(withIdentifier: "PhotosViewController") as! PhotosViewController
        let newPhotos = photoViewsController.selectedPhotos.share()
        newPhotos
//            .filter({ (image) -> Bool in
//                return image.size.width > image.size.height
//            })
            .takeWhile({ [weak self] (image) -> Bool in
                return (self?.images.value.count ?? 0) < 6
            })
            .filter({ [weak self] (image) -> Bool in
                let len = UIImagePNGRepresentation(image)?.count ?? 0
                guard self?.imageCache.contains(len) == false else {
                    return false
                }
                self?.imageCache.append(len)
                return true
            })
            .subscribe(onNext: { [weak self] (photo) in
                self?.images.value.append(photo)
            }) {
                print("Completed photo selection")
            }
            .disposed(by: photoViewsController.bag)
        
        newPhotos
            .ignoreElements()
            .subscribe(onCompleted: { [weak self] in
                self?.updateNavigationIcon()
            })
            .disposed(by: bag)
        
        navigationController?.pushViewController(photoViewsController, animated: true)
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
