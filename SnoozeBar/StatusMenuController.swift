//
//  StatusMenuController.swift
//  SnoozeBar
//
//  Created by Brian Anderson on 6/1/19.
//  Copyright © 2019 Brian Anderson. All rights reserved.
//

import Cocoa


class StatusMenuController: NSObject {
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var statusIndicator: NSMenuItem!
    @IBOutlet weak var statusIndicatorSeparator: NSMenuItem!
    var timer: Timer!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let dnd = DND()
    
    @IBAction func snooze10Minutes(_ sender: NSMenuItem) {
        dnd.enableDND(minutesFromNow: 1)
        setStatus(minutesFromNow: 1)
    }

    @IBAction func snooze30Minutes(_ sender: NSMenuItem) {
        dnd.enableDND(minutesFromNow: 30)
        setStatus(minutesFromNow: 30)

    }

    @IBAction func snooze1HourNew(_ sender: NSMenuItem) {
        dnd.enableDND(minutesFromNow: 60)
        setStatus(minutesFromNow: 60)

    }

    @IBAction func snooze4Hour(_ sender: NSMenuItem) {
        dnd.enableDND(minutesFromNow: 60 * 4)
        setStatus(minutesFromNow: 60*4)

    }

    func setStatus(minutesFromNow: Int) {

        var dateComponent = DateComponents()
        dateComponent.minute = minutesFromNow
        
        let endTime = Calendar.current.date(byAdding: dateComponent, to: Date())
        
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm"
        let dateString = formatter.string(from: endTime!)
        
        statusIndicator.title = "Snoooz'n until " + dateString
        statusIndicator.isHidden = false
        statusIndicatorSeparator.isHidden = false
        
        if((timer != nil) && timer.isValid){
            timer.invalidate();
        }
        
        timer = Timer.scheduledTimer(timeInterval: Double(minutesFromNow * 60), target: self, selector: #selector(hideStatus), userInfo: nil, repeats: false)

    }
    
    @objc func hideStatus(){
        print("Timer is over, back to hiding");
        statusIndicator.isHidden = true
        statusIndicatorSeparator.isHidden = true
    }
    
    override func awakeFromNib() {
        let icon = NSImage(named: "statusIcon")
        icon?.isTemplate = true
        statusItem.button?.image = icon
        statusItem.menu = statusMenu
        
        hideStatus()
    }
    
    @IBAction func quitClicked(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
}
