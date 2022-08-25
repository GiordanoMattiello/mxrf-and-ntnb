//
//  MxrfMLModel.swift
//  mxrf-ntnb
//
//  Created by Giordano Mattiello on 22/08/22.
//

import Foundation
import CoreML

class MxrfMLModel {
    private let mxrfAndNTNBModel:MXRFANDNTNBModel = {
        do {
            let config = MLModelConfiguration()
            return try MXRFANDNTNBModel(configuration: config)
        } catch {
            print(error)
            fatalError("Couldn't create NTNB")
        }
        }()
    
    let  inputExample = MXRFANDNTNBModelInput(Cotacao: 9.0, Cotacao_AVG_30: 9.0, B_Trend_15: 0.001, B_Trend_30: 0.001, B_Trend_120: 0.001, NTN_B_AVG_30: 0.001, Cot_Trend_15: 0.001, Cot_Trend_30: 0.001, Cot_Trend_120: 0.001)


    func predict(input: MXRFANDNTNBModelInput) -> Bool{
        guard let output = try? mxrfAndNTNBModel.prediction(input: input) else {
            return false
        }
        return output.Target == 1
    }

    
    
}
