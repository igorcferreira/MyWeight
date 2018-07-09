//
//  UserActivityService.swift
//  MyWeight
//
//  Created by Diogo on 02/04/17.
//  Copyright © 2017 Diogo Tridapalli. All rights reserved.
//

import Foundation

public protocol UserActivityProtocol {
    func addActivity(with mass: Mass) -> NSUserActivity
    func willContinue(type: String) -> Bool
    func parse(userActivity: NSUserActivity) -> UserActivityService.ActivityType?
    func extract(userActivity: NSUserActivity) -> Mass?
}

public struct UserActivityService: UserActivityProtocol {
    
    fileprivate enum Keys: String {
        case value
        case unit
    }
    
    public enum ActivityType: String, CaseIterable {
        case list = "com.diogot.health.My-Weight.list"
        case add = "com.diogot.health.My-Weight.add"
    }
    
    public func addActivity(with mass: Mass) -> NSUserActivity
    {
        let type = UserActivityService.ActivityType.add
        let userActivity = NSUserActivity(activityType: type.rawValue)
        
        userActivity.title = Localization.addActivityTile
        userActivity.isEligibleForSearch = true
        userActivity.requiredUserInfoKeys = Set([UserActivityService.Keys.unit.rawValue,
                                                 UserActivityService.Keys.value.rawValue])
        userActivity.addUserInfoEntries(from: [Keys.unit.rawValue: mass.value.unit.symbol,
                                               Keys.value.rawValue: mass.value.value])
        
        /*:
         This `isEligibleForPrediction` flag on the userActivity
         donates this activity to the Siri knowledges, allowing
         it to be used by Shortcuts, or Sportlight suggestions.
         
         For now, it is wrapped on a #if because it is part of
         the Beta system.
         */
        #if __IPHONE_12_0
        if #available(iOS 12.0, *) {
            userActivity.isEligibleForPrediction = true
        }
        #endif
        
        return userActivity
    }
    
    public func willContinue(type: String) -> Bool {
        return ActivityType.allCases.contains(where: { $0.rawValue == type })
    }
    
    public func parse(userActivity: NSUserActivity) -> UserActivityService.ActivityType? {
        return ActivityType(rawValue: userActivity.activityType)
    }
    
    public func extract(userActivity: NSUserActivity) -> Mass? {
        guard let userInfo = userActivity.userInfo,
            let value = userInfo[Keys.value.rawValue] as? Double,
            let symbol = userInfo[Keys.unit.rawValue] as? String else {
            return nil
        }
        
        let unit = UnitMass(symbol: symbol)
        let measurement = Measurement(value: value, unit: unit)
        let mass = Mass(value: measurement, date: Date())
        return mass
    }
}
