//
//  ContactInfo.swift
//  VolunQueer
//

import Foundation

struct ContactInfo: Codable, Hashable {
    var email: String?
    var phone: String?
    var preferredChannel: ContactChannel?
}
