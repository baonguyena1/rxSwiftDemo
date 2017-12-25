//
//  CategoriesViewController.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 12/6/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CategoriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    let categories = Variable<[EOCategory]>([])
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
        
        categories
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        startDownload()
    }
    
    func startDownload() {
        let eoCategories = EONET.categories
        let downloadedEvents = EONET.events(forLast: 360)
        
        let updatedCategory = Observable
                .combineLatest(eoCategories, downloadedEvents) { (categories, events) -> [EOCategory] in
                    
                    return categories.map({ (category) in
                        var cat = category
                        cat.events = events.filter({
                            $0.categories.contains(category.id)
                        })
                        return cat
                    })
            }
        
        eoCategories
            .concat(updatedCategory)
            .bind(to: categories)
            .disposed(by: disposeBag)
    }
    
    // MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell") as! CategoryCell
        let category = categories.value[indexPath.row]
        cell.configure(category: category)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories.value[indexPath.row]
        if !category.events.isEmpty {
            let eventController = UIStoryboard(name: "OurPlanet", bundle: nil).instantiateViewController(withIdentifier: "events") as! EventsViewController
            eventController.title = category.name
            eventController.events.value = category.events
            navigationController?.pushViewController(eventController, animated: true)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
