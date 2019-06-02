//
//  DND.swift
//  SnoozeBar
//
//  Created by Brian Anderson on 6/1/19.
//  Copyright © 2019 Brian Anderson. All rights reserved.
//

import Foundation

class DND {
    private func minutesSinceMidnightAdding(minutesFromNow : Int ) -> Int {
        let hour = Calendar.current.component(.hour, from: Date())
        let minute = Calendar.current.component(.minute, from: Date())
        return min(((hour * 60) + minute + minutesFromNow), 1440)
    }
    
    func enableDND(minutesFromNow : Int = 10){
        let computedEndTime = minutesSinceMidnightAdding(minutesFromNow: minutesFromNow);
                
        print("want to set end time")
        print(computedEndTime)
        
        CFPreferencesSetValue("dndStart" as CFString, CGFloat(0) as CFPropertyList, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        
        CFPreferencesSetValue("dndEnd" as CFString, CGFloat(computedEndTime) as CFPropertyList, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        
        CFPreferencesSetValue("doNotDisturb" as CFString, true as CFPropertyList, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        
        
        commitDNDChanges()
        
    }
    
    func disableDND(){
        CFPreferencesSetValue("dndStart" as CFString, nil, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        
        CFPreferencesSetValue("dndEnd" as CFString, nil, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        
        CFPreferencesSetValue("doNotDisturb" as CFString, false as CFPropertyList, "com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        commitDNDChanges()
    }
    
    func commitDNDChanges(){
        CFPreferencesSynchronize("com.apple.notificationcenterui" as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        DistributedNotificationCenter.default().postNotificationName(NSNotification.Name(rawValue: "com.apple.notificationcenterui.dndprefs_changed"), object: nil, userInfo: nil, deliverImmediately: true)
    }
}
