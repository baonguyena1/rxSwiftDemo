//
//  EventCell.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 12/6/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import UIKit

class EventCell: UITableViewCell {
    
    @IBOutlet var title: UILabel!
    @IBOutlet var date: UILabel!
    @IBOutlet var details: UILabel!
    
    func configure(event: EOEvent) {
        title.text = event.title
        details.text = event.description
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        if let when = event.closeDate {
            date.text = formatter.string(for: when)
        } else {
            date.text = ""
        }
    }

}
