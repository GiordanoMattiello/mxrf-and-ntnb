//
//  DateExtension.swift
//  mxrf-ntnb
//
//  Created by Giordano Mattiello on 22/08/22.
//

import Foundation

extension Date{
    static func stringToDatePTBR(_ stringDate: String) -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        dateFormatter.locale = Locale.init(identifier: "pt-br")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date:Date = dateFormatter.date(from: stringDate)!
        return date
    }
}
