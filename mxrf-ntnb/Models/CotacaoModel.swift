//
//  CotacaoModel.swift
//  mxrf-ntnb
//
//  Created by Giordano Mattiello on 23/08/22.
//

import Foundation

class CotacaoRequest:Codable {
    let stockReports: [CotacaoModel]?
}
class CotacaoModel:Codable{
    let fec: String
    let data: String
}
