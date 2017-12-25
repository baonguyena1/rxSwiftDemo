//
//  CategoryCell.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 12/6/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    func configure(category: EOCategory) {
        titleLabel.text = "\(category.name) (\(category.events.count))"
        accessoryType = (category.events.count > 0) ? .disclosureIndicator : .none
        detailLabel.text = category.description
    }

}
