//
//  Chart.swift
//  mxrf-ntnb
//
//  Created by Giordano Mattiello on 24/08/22.
//

import SwiftUI
import SwiftUICharts

struct Chart: View {
    let movingAverage:[Double]
    
    var body: some View {
        VStack{
            LineChart(chartData:  LineChartData(dataSets: LineDataSet(
                dataPoints: dataPointsList()
            )))
        }
    }
    func dataPointsList() -> [LineChartDataPoint] {
        if movingAverage.count > 120 {
            return movingAverage[(movingAverage.count-120)..<movingAverage.count].map({ LineChartDataPoint(value: $0) })
        }
        return movingAverage.map({ LineChartDataPoint(value: $0) })
    }
}


struct Chart_Previews: PreviewProvider {
    static var previews: some View {
        Chart(movingAverage: [0,1,2,3,4,5,6,7])
    }
}
