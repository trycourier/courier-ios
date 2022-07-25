//
//  CourierUserProfile.swift
// 
//
//  Created by Michael Miller on 7/7/22.
//

import Foundation

public struct CourierUserProfile: Codable {
    
    public let id: String
    public let email: String?
    public let email_verified: Bool?
    public let phone_number: String?
    public let phone_number_verified: Bool?
    public let picture: String?
    public let birthdate: String?
    public let gender: String?
    public let profile: String?
    public let sub: String?
    public let name: String?
    public let nickname: String?
    public let preferred_name: String?
    public let preferred_username: String?
    public let given_name: String?
    public let middle_name: String?
    public let family_name: String?
    public let first_name: String?
    public let last_name: String?
    public let locale: String?
    public let zoneinfo: String?
    public let website: String?
    public let updated_at: String?
    public let address: CourierAddress?
    
    public init(
        id: String,
        email: String? = nil,
        email_verified: Bool? = nil,
        phone_number: String? = nil,
        phone_number_verified: Bool? = nil,
        picture: String? = nil,
        birthdate: String? = nil,
        gender: String? = nil,
        profile: String? = nil,
        sub: String? = nil,
        name: String? = nil,
        nickname: String? = nil,
        preferred_name: String? = nil,
        preferred_username: String? = nil,
        given_name: String? = nil,
        middle_name: String? = nil,
        family_name: String? = nil,
        first_name: String? = nil,
        last_name: String? = nil,
        website: String? = nil,
        locale: String? = nil,
        zoneinfo: String? = nil,
        updated_at: String? = nil,
        address: CourierAddress? = nil
    ) {
        self.id = id
        self.email = email
        self.email_verified = email_verified
        self.phone_number = phone_number
        self.phone_number_verified = phone_number_verified
        self.picture = picture
        self.preferred_name = preferred_name
        self.preferred_username = preferred_username
        self.birthdate = birthdate
        self.gender = gender
        self.profile = profile
        self.sub = sub
        self.name = name
        self.nickname = nickname
        self.given_name = given_name
        self.middle_name = middle_name
        self.family_name = family_name
        self.first_name = first_name
        self.last_name = last_name
        self.website = website
        self.zoneinfo = zoneinfo
        self.locale = locale
        self.updated_at = updated_at
        self.address = address
    }
    
}

extension CourierUserProfile {
    
    var toProfile: CourierProfile {
        return CourierProfile(profile: self)
    }
    
}
