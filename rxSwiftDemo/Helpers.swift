//
//  Helpers.swift
//  rxSwiftDemo
//
//  Created by Bao Nguyen on 11/28/17.
//  Copyright © 2017 Bao Nguyen. All rights reserved.
//

import Foundation

func example(description: String, action:(() -> Void)?) {
    print("\n-----", description, "-----")
    if action != nil {
        action!()
    }
}
