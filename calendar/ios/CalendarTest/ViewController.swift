//
//  ViewController.swift
//  CalendarTest
//
//

import UIKit
import EventKit
import Foundation

class ViewController: UIViewController {
    
    // outlets and variables
    
    var timerForRollForward : Timer = Timer()
    
    @IBOutlet weak var autoRollForwardStatus: UILabel!
    
    func createTimer() {
        
        if (!self.timerForRollForward.isValid) { // dont create a duplicate one
            
            self.timerForRollForward = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(ViewController.moveEventsBy1Day), userInfo: nil, repeats: true)
            
        }
        
        self.autoRollForwardStatus.text = "Auto Roll Forward: RUNNING"
        
    }

    @IBAction func startRollForward(_ sender: UIButton) {
        
        let eventStore = EKEventStore()
        
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: {
                granted, error in
                
                self.createTimer()
                
            })
        } else {
            
            createTimer()
        }
        

    }

    @IBAction func stopRollForward(_ sender: UIButton) {
        
        timerForRollForward.invalidate()
        
        autoRollForwardStatus.text = "Auto Roll Forward: STOPPED"
        
    }
    
    func moveEventsBy1Day()
    {
        NSLog("hello World")
    }
    
    
    @IBAction func testFunctionality(_ sender: UIButton) {
        NSLog("Inside Test Function")
        
        let eventStore = EKEventStore()
        let calendars = eventStore.calendars(for: .event)
        
        for calendar in calendars {
            if calendar.title == "Work" {
                
                let oneMonthAgo = Date(timeIntervalSinceNow: -30*24*3600)
                let oneMonthAfter = Date(timeIntervalSinceNow: +30*24*3600)
                
                let predicate = eventStore.predicateForEvents(withStart: oneMonthAgo, end: oneMonthAfter, calendars: [calendar])
                
                let events = eventStore.events(matching: predicate)
                
                for event in events {
                    NSLog(event.title)
                    // NSLog("%@", event.startDate)
                    // NSLog("%@", event.endDate)
                    
                    event.startDate = (Calendar.current as NSCalendar)
                        .date(
                            byAdding: .day,
                            value: 1,
                            to: event.startDate,
                            options: []
                    )!
                    
                    event.endDate = (Calendar.current as NSCalendar)
                        .date(
                            byAdding: .day,
                            value: 1,
                            to: event.endDate,
                            options: []
                    )!
                    
                    do {
                        try eventStore.save(event, span: .thisEvent, commit: true)
                    } catch let specError as NSError {
                        print("A specific error occurred: \(specError)")
                    } catch {
                        print("An error occurred")
                    }
                    
                    
                }
            }
        }
        
    }
    
    var savedEventId : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // Creates an event in the EKEventStore. The method assumes the eventStore is created and 
    // accessible
    func createEvent(_ eventStore: EKEventStore, title: String, startDate: Date, endDate: Date) {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.save(event, span: .thisEvent)
            savedEventId = event.eventIdentifier
        } catch {
            print("Bad things happened")
        }
    }
    
    // Removes an event from the EKEventStore. The method assumes the eventStore is created and
    // accessible
    func deleteEvent(_ eventStore: EKEventStore, eventIdentifier: String) {
        let eventToRemove = eventStore.event(withIdentifier: eventIdentifier)
        if (eventToRemove != nil) {
            do {
                try eventStore.remove(eventToRemove!, span: .thisEvent)
            } catch {
                print("Bad things happened")
            }
        }
    }
    
    // Responds to button to add event. This checks that we have permission first, before adding the
    // event
    @IBAction func addEvent(_ sender: UIButton) {
        
        let eventStore = EKEventStore()
        
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(60 * 60) // One hour
        
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: {
                granted, error in
                self.createEvent(eventStore, title: "DJ's Test Event", startDate: startDate, endDate: endDate)
            })
        } else {
            createEvent(eventStore, title: "DJ's Test Event", startDate: startDate, endDate: endDate)
        }
    }


    // Responds to button to remove event. This checks that we have permission first, before removing the
    // event
    @IBAction func removeEvent(_ sender: UIButton) {
        let eventStore = EKEventStore()
        
        if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
            eventStore.requestAccess(to: .event, completion: { (granted, error) -> Void in
                self.deleteEvent(eventStore, eventIdentifier: self.savedEventId)
            })
        } else {
            deleteEvent(eventStore, eventIdentifier: savedEventId)
        }

    }
}

