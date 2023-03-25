//
//  ScheduleModel.swift
//  Scheduler
//
//  Created by Shishir_Mac on 25/3/23.
//

import Foundation

class ScheduledItem: Codable, Equatable {
    let id: String
    let date: Date
    let title: String
    let description: String?

    init(date: Date, title: String, description: String? = nil) {
        self.id = UUID().uuidString
        self.date = date
        self.title = title
        self.description = description
    }

    static func == (lhs: ScheduledItem, rhs: ScheduledItem) -> Bool {
        return lhs.id == rhs.id
    }
}
