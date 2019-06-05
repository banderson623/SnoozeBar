//
//  DND.swift
//  SnoozeBar
//
//  Created by Brian Anderson on 6/1/19.
//  Copyright © 2019 Brian Anderson. All rights reserved.
//

import Foundation
import os

class DND {

  let log = OSLog.init(subsystem: "com.bitbyteyum.SnoozeBar", category: "DND")

  static let notificationCenterId = "com.apple.notificationcenterui" as CFString

  private func minutesSinceMidnightAdding(minutesFromNow : Int ) -> Int {
    let hour = Calendar.current.component(.hour, from: Date())
    let minute = Calendar.current.component(.minute, from: Date())
    return min(((hour * 60) + minute + minutesFromNow), 1440)
  }

  private func dateFromMinutesSinceMidnight(minutesSinceMidnight: Int) -> Date {
    let date = Date()
    let cal = Calendar(identifier: .gregorian)
    let midnight = cal.startOfDay(for: date)

    var dateComponent = DateComponents()
    dateComponent.minute = minutesSinceMidnight
    guard let endingDate = Calendar.current.date(byAdding: dateComponent, to: midnight) else {
      return Date() }
    return endingDate
  }

  func isEnabled() -> Bool {
    return CFPreferencesGetAppBooleanValue("doNotDisturb" as CFString, DND.notificationCenterId, nil)
  }

  func dndEndTime() -> Date {
    let minutesSinceMidnight = CFPreferencesGetAppIntegerValue("dndEnd" as CFString, DND.notificationCenterId, nil)
    return dateFromMinutesSinceMidnight(minutesSinceMidnight: minutesSinceMidnight)
  }

    func enableDND(minutesFromNow : Int = 10){
        let computedEndTime = minutesSinceMidnightAdding(minutesFromNow: minutesFromNow);
        
        os_log("Enabling Do Not Disturb for %d minutes, computed to %d minutes since midnight", log: log,
               minutesFromNow, computedEndTime)
        
      CFPreferencesSetValue("dndStart" as CFString, CGFloat(0) as CFPropertyList, DND.notificationCenterId as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        
      CFPreferencesSetValue("dndEnd" as CFString, CGFloat(computedEndTime) as CFPropertyList, DND.notificationCenterId as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        
      CFPreferencesSetValue("doNotDisturb" as CFString, true as CFPropertyList, DND.notificationCenterId as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        
        commitDNDChanges()
        
    }
    
    func disableDND(){
      CFPreferencesSetValue("dndStart" as CFString, nil, DND.notificationCenterId as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        
      CFPreferencesSetValue("dndEnd" as CFString, nil, DND.notificationCenterId as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        
      CFPreferencesSetValue("doNotDisturb" as CFString, false as CFPropertyList, DND.notificationCenterId as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        commitDNDChanges()
    }
    
    func commitDNDChanges(){
      CFPreferencesSynchronize(DND.notificationCenterId as CFString, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost)
        DistributedNotificationCenter.default().postNotificationName(NSNotification.Name(rawValue: "com.apple.notificationcenterui.dndprefs_changed"), object: nil, userInfo: nil, deliverImmediately: true)
    }
}
