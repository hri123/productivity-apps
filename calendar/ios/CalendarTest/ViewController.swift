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
    
    var timerForRollForward : NSTimer = NSTimer()
    
    @IBOutlet weak var autoRollForwardStatus: UILabel!
    
    func createTimer() {
        
        if (!self.timerForRollForward.valid) { // dont create a duplicate one
            
            self.timerForRollForward = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController.moveEventsBy1Day), userInfo: nil, repeats: true)
            
        }
        
        self.autoRollForwardStatus.text = "Auto Roll Forward: RUNNING"
        
    }

    @IBAction func startRollForward(sender: UIButton) {
        
        let eventStore = EKEventStore()
        
        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
            eventStore.requestAccessToEntityType(.Event, completion: {
                granted, error in
                
                self.createTimer()
                
            })
        } else {
            
            createTimer()
        }
        

    }

    @IBAction func stopRollForward(sender: UIButton) {
        
        timerForRollForward.invalidate()
        
        autoRollForwardStatus.text = "Auto Roll Forward: STOPPED"
        
    }
    
    func moveEventsBy1Day()
    {
        NSLog("hello World")
    }
    
    
    @IBAction func testFunctionality(sender: UIButton) {
        NSLog("Inside Test Function")
        
        let eventStore = EKEventStore()
        let calendars = eventStore.calendarsForEntityType(.Event)
        
        for calendar in calendars {
            if calendar.title == "Work" {
                
                let oneMonthAgo = NSDate(timeIntervalSinceNow: -30*24*3600)
                let oneMonthAfter = NSDate(timeIntervalSinceNow: +30*24*3600)
                
                let predicate = eventStore.predicateForEventsWithStartDate(oneMonthAgo, endDate: oneMonthAfter, calendars: [calendar])
                
                let events = eventStore.eventsMatchingPredicate(predicate)
                
                for event in events {
                    NSLog(event.title)
                    NSLog("%@", event.startDate)
                    NSLog("%@", event.endDate)
                    
                    event.startDate = NSCalendar.currentCalendar()
                        .dateByAddingUnit(
                            .Day,
                            value: 1,
                            toDate: event.startDate,
                            options: []
                    )!
                    
                    event.endDate = NSCalendar.currentCalendar()
                        .dateByAddingUnit(
                            .Day,
                            value: 1,
                            toDate: event.endDate,
                            options: []
                    )!
                    
                    do {
                        try eventStore.saveEvent(event, span: .ThisEvent, commit: true)
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
    func createEvent(eventStore: EKEventStore, title: String, startDate: NSDate, endDate: NSDate) {
        let event = EKEvent(eventStore: eventStore)
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.saveEvent(event, span: .ThisEvent)
            savedEventId = event.eventIdentifier
        } catch {
            print("Bad things happened")
        }
    }
    
    // Removes an event from the EKEventStore. The method assumes the eventStore is created and
    // accessible
    func deleteEvent(eventStore: EKEventStore, eventIdentifier: String) {
        let eventToRemove = eventStore.eventWithIdentifier(eventIdentifier)
        if (eventToRemove != nil) {
            do {
                try eventStore.removeEvent(eventToRemove!, span: .ThisEvent)
            } catch {
                print("Bad things happened")
            }
        }
    }
    
    // Responds to button to add event. This checks that we have permission first, before adding the
    // event
    @IBAction func addEvent(sender: UIButton) {
        
        let eventStore = EKEventStore()
        
        let startDate = NSDate()
        let endDate = startDate.dateByAddingTimeInterval(60 * 60) // One hour
        
        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
            eventStore.requestAccessToEntityType(.Event, completion: {
                granted, error in
                self.createEvent(eventStore, title: "DJ's Test Event", startDate: startDate, endDate: endDate)
            })
        } else {
            createEvent(eventStore, title: "DJ's Test Event", startDate: startDate, endDate: endDate)
        }
    }


    // Responds to button to remove event. This checks that we have permission first, before removing the
    // event
    @IBAction func removeEvent(sender: UIButton) {
        let eventStore = EKEventStore()
        
        if (EKEventStore.authorizationStatusForEntityType(.Event) != EKAuthorizationStatus.Authorized) {
            eventStore.requestAccessToEntityType(.Event, completion: { (granted, error) -> Void in
                self.deleteEvent(eventStore, eventIdentifier: self.savedEventId)
            })
        } else {
            deleteEvent(eventStore, eventIdentifier: savedEventId)
        }

    }
}

