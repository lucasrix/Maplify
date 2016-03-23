//
//  AttachmentManager.swift
//  Maplify
//
//  Created by Antonoff Evgeniy on 3/22/16.
//  Copyright © 2016 rubygarage. All rights reserved.
//

import Tailor

class AttachmentManager: ModelManager {
    override func manageResponse(response: [String : AnyObject]) -> AnyObject! {
        let dictionary = (response["attachment"] != nil) ? (response["attachment"] as! [String : AnyObject]) : response
        return Attachment(dictionary)
    }
}
