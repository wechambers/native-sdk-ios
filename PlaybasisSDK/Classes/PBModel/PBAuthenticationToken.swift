//
//  AuthenticationToken.swift
//  Idea
//
//  Created by Médéric Petit on 4/20/2559 BE.
//  Copyright © 2559 playbasis. All rights reserved.
//

import UIKit
import SAMKeychain
import ObjectMapper

let expirationDateKey:String = "expirationDateKey"

class PBAuthenticationToken: Mappable {
    
    var token:String? = nil
    var expirationDate:NSDate? = nil
    
    init(apiResponse:PBApiResponse) {
        Mapper<PBAuthenticationToken>().map(apiResponse.parsedJson, toObject: self)
    }
    
    init() {
        self.getFromKeychain()
    }
    
    required init?(_ map: Map){
    }
    
    func mapping(map: Map) {
        token <- map["token"]
        expirationDate <- (map["date_expire"], ISO8601DateTransform())
        self.saveInKeychain()
    }
    
    func isExpiredOrInvalid() -> Bool {
        return expirationDate == nil || self.token == nil || (expirationDate!.compare(NSDate()) == .OrderedAscending || expirationDate!.compare(NSDate()) == .OrderedSame)
    }
    
    private func saveInKeychain() {
        if let token = self.token {
            PBDataManager.sharedInstance.saveToken(token, withType: .AuthenticationToken)
            PBDataManager.sharedInstance.saveValue(expirationDate, forKey: expirationDateKey)
        }
    }
    
    private func clearKeyChain() {
        PBDataManager.sharedInstance.clearToken()
        PBDataManager.sharedInstance.unsetValueFromKey(expirationDateKey)
    }
    
    func getFromKeychain() {
        self.token = PBDataManager.sharedInstance.getTokenWithType(.AuthenticationToken)
        self.expirationDate = PBDataManager.sharedInstance.valueForKey(expirationDateKey) as? NSDate
    }
    
    func invalidate() {
        self.token = nil
        self.expirationDate = nil
        self.clearKeyChain()
    }
}
