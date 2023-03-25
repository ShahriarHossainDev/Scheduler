//
//  ScheduleViewController.swift
//  Scheduler
//
//  Created by Shishir_Mac on 25/3/23.
//

import UIKit
import FSCalendar
import UserNotifications

class ScheduleViewController: UIViewController {
    
    @IBOutlet weak var topTitleLabel: UILabel!
    
    @IBOutlet weak var schedulerTableView: UITableView!
    @IBOutlet weak var calenderFSCalendar: FSCalendar!
    
    var selectedDate: Date?
    var scheduledItems: [ScheduledItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calenderFSCalendar.dataSource = self
        calenderFSCalendar.delegate = self
        calenderFSCalendar.appearance.todayColor = UIColor.red // Customize the appearance
        calenderFSCalendar.scope = .month // Show the current month by default
        
        // Set up the scheduled items table view
        schedulerTableView.dataSource = self
        schedulerTableView.delegate = self
        //schedulerTableView.register(ScheduledItemCell.self, forCellReuseIdentifier: "ScheduledItemCell")
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Function
    func contenSetup() {
        topTitleLabel.text = "Select the meeting of which you want to create a new."
        
    }
    
    func scheduleNotification(for item: ScheduledItem) {
        let content = UNMutableNotificationContent()
        content.title = item.title
        content.body = item.description ?? ""
        content.sound = UNNotificationSound.default
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: item.id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for item \(item.id): \(error.localizedDescription)")
            } else {
                print("Notification scheduled for item \(item.id)")
            }
        }
    }
    
    // MARK: -  IBAction
    @IBAction func addButtonTapped(_ sender: UIButton) {
        // Show a form to allow the user to add a new scheduled item
        let alertController = UIAlertController(title: "Add Scheduled Item", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Title"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Description (Optional)"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            guard let selectedDate = self.selectedDate else {
                return
            }
            guard let title = alertController.textFields?[0].text, !title.isEmpty else {
                return
            }
            let description = alertController.textFields?[1].text
            let newItem = ScheduledItem(date: selectedDate, title: title, description: description)
            self.scheduledItems.append(newItem)
            self.scheduledItems.sort { $0.date < $1.date }
            self.schedulerTableView.reloadData()
            self.scheduleNotification(for: newItem)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(addAction)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension ScheduleViewController: FSCalendarDataSource, FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        selectedDate = date
        schedulerTableView.reloadData()
    }
    
}

extension ScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let selectedDate = selectedDate else {
            return 0
        }
        let scheduledItemsForSelectedDate = scheduledItems.filter({ $0.date == selectedDate })
        return scheduledItemsForSelectedDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduledItemCell", for: indexPath)
        guard let selectedDate = selectedDate else {
            return cell
        }
        let scheduledItemsForSelectedDate = scheduledItems.filter({ $0.date == selectedDate })
        cell.textLabel?.text = scheduledItemsForSelectedDate[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Show an alert to allow the user to delete the selected scheduled item
        let alertController = UIAlertController(title: "Delete Scheduled Item", message: "Are you sure you want to delete this item?", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] (action) in
            guard let selectedDate = self.selectedDate else {
                return
            }
            let scheduledItemsForSelectedDate = self.scheduledItems.filter({ $0.date == selectedDate })
            let itemToDelete = scheduledItems
            let item = scheduledItemsForSelectedDate[indexPath.row]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id])
            self.scheduledItems.removeAll(where: { $0 == item })
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
}
