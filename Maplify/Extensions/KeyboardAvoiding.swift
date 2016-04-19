//
//  KeyboardAvoiding.swift
//  Maplify
//
//  Created by Sergei on 11/04/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import TPKeyboardAvoiding

extension TPKeyboardAvoidingScrollView {
    func disableKeyboardAvoiding() {
        self.scrollEnabled = false
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
