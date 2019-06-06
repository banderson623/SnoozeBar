//
//  StatusMenuController.swift
//  SnoozeBar
//
//  Created by Brian Anderson on 6/1/19.
//  Copyright © 2019 Brian Anderson. All rights reserved.
//

import Cocoa
import os

class StatusMenuController: NSObject {
  @IBOutlet weak var resumeMenuItem: NSMenuItem!
  @IBOutlet weak var statusMenu: NSMenu!
  @IBOutlet weak var statusIndicator: NSMenuItem!
  @IBOutlet weak var statusIndicatorSeparator: NSMenuItem!

  var timer: Timer!
  let log = OSLog.init(subsystem: "com.bitbyteyum.SnoozeBar", category: "MenuController")
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
  let dnd = DND()

  var dndEndDate = Date.init(timeIntervalSince1970: 0)
  var lastCheckWasDndEnabled = -1

  let readyIcon = NSImage(named: "readyIcon")
  let snoozingIcon = NSImage(named: "snoozingIcon")

  @IBAction func snooze10Minutes(_ sender: NSMenuItem) {
    dnd.enableDND(minutesFromNow: 10)
    dndStateObserver()
  }

  @IBAction func snooze30Minutes(_ sender: NSMenuItem) {
    dnd.enableDND(minutesFromNow: 30)
    dndStateObserver()
  }

  @IBAction func snooze1HourNew(_ sender: NSMenuItem) {
    dnd.enableDND(minutesFromNow: 60)
    dndStateObserver()
  }

  @IBAction func snooze4Hour(_ sender: NSMenuItem) {
    dnd.enableDND(minutesFromNow: 60 * 4)
    dndStateObserver()
  }

  @IBAction func resumeNotifications(_ sender: NSMenuItem) {
    dnd.disableDND()
    dndStateObserver()
  }

  @IBAction func quitClicked(_ sender: NSMenuItem) {
    NSApplication.shared.terminate(self)
  }

  func dndEnabled(){
    if(lastCheckWasDndEnabled != 1) {
      let endTime = dnd.dndEndTime()
      let formatter = DateFormatter()
      formatter.dateFormat = "hh:mm"
      let until = (endTime > Date()) ? formatter.string(from: endTime) : "midnight"
      os_log("dnd is transitioning to enabled, until %{public}s", log: log, until)

      statusItem.button?.image = snoozingIcon
      statusIndicator.title = "Snoooz'n until " + until
      statusIndicator.isHidden = false
      statusIndicatorSeparator.isHidden = false
      resumeMenuItem.isHidden = false
      lastCheckWasDndEnabled = 1
    }
  }
    
  func dndIsOver(){
    if(lastCheckWasDndEnabled != 0) {
      os_log("dnd is transitioning to over", log: log)

      statusItem.button?.image = readyIcon
      statusIndicator.isHidden = true
      statusIndicatorSeparator.isHidden = true
      resumeMenuItem.isHidden = true
      lastCheckWasDndEnabled = 0
    }
  }

  override func awakeFromNib() {
    statusItem.menu = statusMenu
    dndStateObserver()
    if((timer == nil) || !timer.isValid){
      timer = Timer.scheduledTimer(timeInterval: 30.0,
                                   target: self,
                                   selector: #selector(dndStateObserver),
                                   userInfo: nil,
                                   repeats: true)
    }
  }

  @objc func dndStateObserver() {
    os_log("dnd EndTime is %{public}s | %{public}s", log: log,
           dnd.dndEndTime().description(with: NSLocale.autoupdatingCurrent),
           dnd.isEnabled() ? "Enabled" : "Disabled")
    let isEnabled = dnd.isEnabled()

    if(isEnabled){
      dndEnabled()
    } else {
      dndIsOver()
    }
  }

}
