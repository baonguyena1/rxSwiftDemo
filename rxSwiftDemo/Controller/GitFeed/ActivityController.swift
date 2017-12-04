//
//  ActivityController.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 12/4/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ActivityController: UITableViewController {
    
    let repo = "ReactiveX/RxSwift"
    
    fileprivate let events = Variable<[Event]>([])
    fileprivate let bag = DisposeBag()
    fileprivate lazy var eventsFileURL = cachedFileURL("events.plist")
    fileprivate lazy var modifiedFileURL = cachedFileURL("modified.txt")
    
    func cachedFileURL(_ fileName: String) -> URL {
        return FileManager.default
            .urls(for: .cachesDirectory, in: .allDomainsMask)
            .first!
            .appendingPathComponent(fileName, isDirectory: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = repo
        
        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        
        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        events.asObservable()
            .subscribe(onNext: { [weak self] (newEvents) in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    refreshControl.endRefreshing()
                }
            })
            .disposed(by: bag)
        
        let eventsArray = (NSArray(contentsOf: eventsFileURL)
            as? [AnyDict]) ?? []
        events.value = eventsArray.flatMap(Event.init)
        
        refresh()
    }

    @objc func refresh() {
        fetchEvents(repo: repo)
    }
    
    func fetchEvents(repo: String) {
        let response = Observable.from([repo])
        response
            .map { (urlString) -> URL in
                    return URL(string: "https://api.github.com/repos/\(urlString)/events")!
            }
            .map { (url) -> URLRequest in
                return URLRequest(url: url)
            }
            .flatMap { (request) -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .share(replay: 1, scope: .whileConnected)
            .filter { (response, data) -> Bool in
                return 200..<300 ~= response.statusCode
            }
            .map { (_, data) -> [AnyDict] in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments), let result = jsonObject as? [AnyDict] else {
                    return []
                }
                return result
            }
            .filter {
                $0.count > 0
            }
            .map({ (objects) in
                objects.flatMap(Event.init)
            })
            .subscribe(onNext: { [weak self] (newEvents) in
                self?.processEvents(newEvents)
            })
            .disposed(by: bag)
    }
    
    func processEvents(_ newEvents: [Event]) {
        var updatedEvents = newEvents + events.value
        if updatedEvents.count > 50 {
            updatedEvents = Array<Event>(updatedEvents.prefix(upTo: 50))
        }
        events.value = updatedEvents
        let eventsArray = updatedEvents.map { $0.dictionary } as NSArray
        eventsArray.write(to: eventsFileURL, atomically: true)
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.value.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = events.value[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.repo + ", " + event.action.replacingOccurrences(of: "Event", with: "").lowercased()
        cell.imageView?.kf.setImage(with: event.imageUrl, placeholder: UIImage(named: "blank-avatar"))
        return cell
    }

}
