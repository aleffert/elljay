//
//  EphemeralUserDataStore.swift
//  elljay
//
//  Created by Akiva Leffert on 2/15/15.
//  Copyright (c) 2015 Akiva Leffert. All rights reserved.
//

import UIKit

import elljay

public class EphemeralUserDataStore : UserDataStore {
    deinit {
        clear()
    }
}