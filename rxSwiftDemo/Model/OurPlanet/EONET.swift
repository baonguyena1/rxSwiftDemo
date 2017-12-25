//
//  File.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 12/6/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class EONET {
    static let API = "https://eonet.sci.gsfc.nasa.gov/api/v2.1"
    static let categoriesEndpoint = "/categories"
    static let eventsEndpoint = "/events"
    
    static var ISODateReader: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        return formatter
    }()
    
    static func filteredEvents(events: [EOEvent], forCategory category: EOCategory) -> [EOEvent] {
        return events.filter { event in
            return event.categories.contains(category.id) &&
                !category.events.contains {
                    $0.id == event.id
            }
            }
            .sorted(by: EOEvent.compareDates)
    }
    
    static func request(endPoint: String, query: [String: Any] = [:]) -> Observable<[String: Any]> {
        do {
            guard let url = URL(string: API)?.appendingPathComponent(endPoint),
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                throw EOError.invalidURL(endPoint)
            }
            components.queryItems = try query.flatMap({ (key, value) in
                guard let v = value as? CustomStringConvertible else {
                    throw EOError.invalidParameter(key, value)
                }
                return URLQueryItem(name: key, value: v.description)
            })
            
            guard let finalURL = components.url else {
                throw EOError.invalidURL(endPoint)
            }
            
            let request = URLRequest(url: finalURL)
            return URLSession.shared.rx.response(request: request)
                .map({ (_, data) -> [String: Any] in
                    guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: .allowFragments),
                        let result = jsonObject as? [String: Any] else {
                        throw EOError.invalidJSON(finalURL.absoluteString)
                    }
                    return result
                })
        } catch {
            return Observable.empty()
        }
    }
    
    static var categories: Observable<[EOCategory]> = {
        return EONET.request(endPoint: categoriesEndpoint)
            .map({ (data) in
                let categories:[[String: Any]] = data["categories"] as? [[String: Any]] ?? []
                return categories
                    .flatMap(EOCategory.init)
                    .sorted(by: { $0.name < $1.name })
            })
            .share(replay: 1, scope: .whileConnected)
        
    }()
    
    fileprivate static func event(forlast days: Int, closed: Bool) -> Observable<[EOEvent]> {
        return request(endPoint: eventsEndpoint, query: [
            "days": NSNumber(value: days),
            "status": (closed ? "closed": "open")
            ])
            .map({ (json) in
                guard let raw = json["events"] as? [[String: Any]] else {
                    throw EOError.invalidJSON(eventsEndpoint)
                }
                return raw.flatMap(EOEvent.init)
            })
    }
    
    static func events(forLast days: Int = 360) -> Observable<[EOEvent]> {
        let openEvents = event(forlast: days, closed: false)
        let closedEvents = event(forlast: days, closed: true)
        return Observable.of(openEvents, closedEvents)
            .merge()
            .reduce([], accumulator: { (running, new) in
                running + new
            })
    }
    
}
