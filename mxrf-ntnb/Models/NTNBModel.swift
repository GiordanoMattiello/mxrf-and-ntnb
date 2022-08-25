//
//  NTNBModel.swift
//  mxrf-ntnb
//
//  Created by Giordano Mattiello on 22/08/22.
//

import Foundation

class NTNBModel:Codable {
    let dueDate: Date
    let date: Date
    let tax: Double
    
    init(dueDate: Date,date: Date,tax: Double){
        self.date = date
        self.dueDate = dueDate
        self.tax = tax
    }
    init(dueDate: String,date: String,tax: String){
        self.date = Date.stringToDatePTBR(date)
        self.dueDate = Date.stringToDatePTBR(dueDate)
        self.tax = Double(tax.replacingOccurrences(of: ",", with: "."))!/100
    }
    
    func description() -> String{
        return "DueDate: \(dueDate.formatted()), Date: \(date.formatted()), Tax: \(tax)"
    }

}


