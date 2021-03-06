//
//  AppDelegate.swift
//  Pomodoro
//
//  Created by Apostolos Papadopoulos on 4/13/18.
//  MIT, 2018 Apostolos Papadopoulos.
//

import Cocoa
import Foundation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate,
                                NSUserNotificationCenterDelegate {
    
    let statusItem = NSStatusBar.system.statusItem(
        withLength:NSStatusItem.squareLength)

    var count = 1500
    var countBreak = 300
    var counterLock = false
    var breakLock = false
    var timer = Timer()
    var timerBreak = Timer()

    let menu = NSMenu()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            button.image = NSImage(named:NSImage.Name("StatusBarButtonImage"))
        }
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func constructMenu() {
        menu.addItem(NSMenuItem(title: "No Timer started", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Start Task",
                                action: #selector(AppDelegate.update(_:)),
                                keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Start Break",
                                action: #selector(AppDelegate.updateBreak(_:)),
                                keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Pomodoro",
                                action: #selector(NSApplication.terminate(_:)),
                                keyEquivalent: ""))
        
        statusItem.menu = menu
    }

    @objc func update(_ sender: Any?) {
        if counterLock == false {
            timer = Timer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         selector: #selector(runTimedCode),
                                         userInfo: nil,
                                         repeats: true)
            counterLock = true
            renameTaskItem(item_name_old: "Start Task",
                           item_name_new: "Stop Task",
                           item_position: 1)
        } else {
            reset()
            renameTaskItem(item_name_old: "Stop Task",
                           item_name_new: "Start Task",
                           item_position: 1)
        }
    }

    @objc func updateBreak(_ sender: Any?) {
        if breakLock == false {
            timerBreak = Timer.scheduledTimer(timeInterval: 1,
                                              target: self,
                                              selector: #selector(runBreakCode),
                                              userInfo: nil,
                                              repeats: true)
            breakLock = true
            renameBreakItem(item_name_old: "Start Break",
                            item_name_new: "Stop Break",
                            item_position: 2)
        } else {
            reset()
            renameBreakItem(item_name_old: "Stop Break",
                            item_name_new: "Start Break",
                            item_position: 2)
        }
    }

    func renameTaskItem(item_name_old: String,
                        item_name_new: String,
                        item_position: Int) {
        menu.removeItem(menu.item(withTitle: item_name_old)!)
        menu.insertItem(withTitle: item_name_new,
                        action: #selector(AppDelegate.update(_:)),
                        keyEquivalent: "",
                        at: item_position)
    }

    func renameBreakItem(item_name_old: String,
                         item_name_new: String,
                         item_position: Int) {
        menu.removeItem(menu.item(withTitle: item_name_old)!)
        menu.insertItem(withTitle: item_name_new,
                        action: #selector(AppDelegate.updateBreak(_:)),
                        keyEquivalent: "",
                        at: item_position)
    }
    
    func renameTimerItem(item_name_new: String,
                         item_position: Int) {
        menu.removeItem(menu.item(at: 0)!)
        menu.insertItem(withTitle: item_name_new,
                        action: nil,
                        keyEquivalent: "",
                        at: item_position)
    }

    func reset() {
        timer.invalidate()
        timerBreak.invalidate()
        counterLock = false
        breakLock = false
        count = 1500
        countBreak = 300
    }

    @objc func runTimedCode() {
        if (count > 0) {
            let minutes = String(count / 60)
            let seconds = String(count % 60)
            let countDownLabel = minutes + ":" + seconds
            count -= 1
            print(countDownLabel)
            renameTimerItem(item_name_new: countDownLabel,
                            item_position: 0
            )
        } else {
            showNotification(content: "Your task is over. Time for a break!")
            reset()
            renameTaskItem(item_name_old: "Stop Task",
                           item_name_new: "Start Task",
                           item_position: 1)
        }
    }

    @objc func runBreakCode() {
        if (countBreak > 0) {
            let minutes = String(countBreak / 60)
            let seconds = String(countBreak % 60)
            let countDownLabel = minutes + ":" + seconds
            countBreak -= 1
            print(countDownLabel)
        } else {
            showNotification(content: "Your break is over. Time for a new task!")
            reset()
            renameBreakItem(item_name_old: "Stop Break",
                            item_name_new: "Start Break",
                            item_position: 2)
        }
    }

    func showNotification(content: String) -> Void {
        let notification = NSUserNotification()
        let nuuid = UUID().uuidString

        notification.identifier = nuuid
        notification.title = "Pomodoro"
        notification.informativeText = content
        notification.soundName = NSUserNotificationDefaultSoundName

        _ = NSUserNotificationCenter.default.deliver(notification)
    }
}

