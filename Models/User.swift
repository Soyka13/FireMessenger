//
//  User.swift
//  Messenger
//
//  Created by Olena Stepaniuk on 08.11.2020.
//

import Foundation

struct User {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
