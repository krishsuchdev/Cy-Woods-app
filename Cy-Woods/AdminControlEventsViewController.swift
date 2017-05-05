//
//  AdminControlEventsViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 11/5/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import Firebase

class AdminControlEventsViewController: UITableViewController {
  
  var firebaseReference = Database.database().reference()
  
  var events = [EventsItem]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.firebaseReference.child("Home Tab").child("Events").observeSingleEvent(of: .value, with: { (snapshot) in
      self.events = [EventsItem]()
      for (_, eventInfo) in snapshot.value! as! NSDictionary {
        let title = (eventInfo as! NSDictionary)["Title"] as! String
        let date = (eventInfo as! NSDictionary)["Date"] as! String
        let color = (eventInfo as! NSDictionary)["Color"] as! String
        let priority = (eventInfo as! NSDictionary)["Priority"] as! Int
        if title != "No Upcoming Events" {
          self.events.append(EventsItem(title: title, date: date, color: color, priority: priority))
        }
      }
      self.events.sort()
      self.tableView.setEditing(true, animated: false)
      self.tableView.reloadData()
    })
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    self.firebaseReference.child("Home Tab").child("Events").removeValue()
    if self.events.isEmpty {
      self.events.append(EventsItem(title: "No Upcoming Events", date: "- -", color: "Gray", priority: 0))
    }
    for eventIndex in 0..<self.events.count {
      var event = self.events[eventIndex]
      event.priority = eventIndex
      self.firebaseReference.child("Home Tab").child("Events").child("E\(eventIndex) \(event.title.prefix(8).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))").updateChildValues(["Title" : event.title, "Date" : event.date, "Color" : event.color, "Priority" : event.priority])
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.events.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
    
    let event = self.events[indexPath.row]
    
    cell.textLabel!.text = event.title
    cell.detailTextLabel!.text = event.date
    cell.detailTextLabel!.textColor = EventsManager.getEventColor(from: event.color)
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let eventEditAlert = UIAlertController(title: "Edit Event", message: "Format the date like \"Tue, Mar 14\"", preferredStyle: UIAlertControllerStyle.alert)
    eventEditAlert.addTextField(configurationHandler: {(textField: UITextField!) in
      textField.placeholder = "Event Name"
      textField.text = self.events[indexPath.row].title
    })
    eventEditAlert.addTextField(configurationHandler: {(textField: UITextField!) in
      textField.placeholder = "Date"
      textField.text = self.events[indexPath.row].date
    })
    eventEditAlert.addTextField(configurationHandler: {(textField: UITextField!) in
      textField.placeholder = "Color"
      textField.text = self.events[indexPath.row].color
    })
    eventEditAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
      tableView.deselectRow(at: indexPath, animated: true)
    }))
    eventEditAlert.addAction(UIAlertAction(title: "Update", style: UIAlertActionStyle.default, handler: { (_) -> Void in
      self.events[indexPath.row].title = eventEditAlert.textFields![0].text!
      self.events[indexPath.row].date  = eventEditAlert.textFields![1].text!
      self.events[indexPath.row].color = eventEditAlert.textFields![2].text!
      self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
      tableView.deselectRow(at: indexPath, animated: true)
    }))
    self.present(eventEditAlert, animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    self.events.swapAt(sourceIndexPath.row, destinationIndexPath.row)
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      self.events.remove(at: indexPath.row)
      self.tableView.deleteRows(at: [indexPath], with: .left)
    }
  }
  
  @IBAction func add(_ sender: Any) {
    let eventAddAlert = UIAlertController(title: "Edit Event", message: "Format the date like \"Tue, Mar 14\"", preferredStyle: UIAlertControllerStyle.alert)
    eventAddAlert.addTextField(configurationHandler: {(textField: UITextField!) in
      textField.placeholder = "Event Name"
    })
    eventAddAlert.addTextField(configurationHandler: {(textField: UITextField!) in
      textField.placeholder = "Date"
    })
    eventAddAlert.addTextField(configurationHandler: {(textField: UITextField!) in
      textField.placeholder = "Color"
    })
    eventAddAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
    }))
    eventAddAlert.addAction(UIAlertAction(title: "Update", style: UIAlertActionStyle.default, handler: { (_) -> Void in
      let newEvent = EventsItem(title: eventAddAlert.textFields![0].text!, date: eventAddAlert.textFields![1].text!, color: eventAddAlert.textFields![2].text!, priority: self.events.count)
      self.events.append(newEvent)
      self.tableView.insertRows(at: [IndexPath(row: self.events.count - 1, section: 0)], with: .right)
    }))
    self.present(eventAddAlert, animated: true, completion: nil)
  }
  
}
