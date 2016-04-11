//
//  KeyboardAvoiding.swift
//  Maplify
//
//  Created by Sergei on 11/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import TPKeyboardAvoiding

extension TPKeyboardAvoidingScrollView {
    func setAvoidingEnabled(enabled: Bool) {
        if enabled == false {
            self.scrollEnabled = false
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
}
