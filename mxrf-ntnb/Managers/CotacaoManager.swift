//
//  cotacaoManager.swift
//  mxrf-ntnb
//
//  Created by Giordano Mattiello on 23/08/22.
//

import Foundation

class CotacaoManager: ObservableObject{
    let dataBaseURL = "https://fiis.com.br/mxrf/cotacoes/?periodo=max"
    var cotacao:[CotacaoModel]? = nil
    var mediaMovelCotacao:[Double] = []
    @Published var allDataReady: Bool = false
    var trends:[Int:Double] = [15:0.0 ,30:0.0, 120:0.0]
    var ultimaCotacao:Double = 0.0
    var ultimaMediaMovel: Double = 0.0
    
    func configure(completionHandler: @escaping () -> Void){
        self.downloadCotacao(){
            self.movingAverage(window: 30) {
                self.gerateTrens(){
                    DispatchQueue.main.async {
                        self.allDataReady = true
                    }
                    self.ultimaCotacao = Double(self.cotacao?.last?.fec ?? "0.0") ?? 0.0
                    self.ultimaMediaMovel = self.mediaMovelCotacao.last ?? 0.0
                    completionHandler()
                    
                }
            }
        }
    }
    func downloadCotacao(completionHandler: @escaping () -> Void){
        if let url = URL(string: dataBaseURL) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else { return }
                do {
                    let res = try JSONDecoder().decode(CotacaoRequest.self, from: data)
                    self.cotacao = res.stockReports
                } catch let error {
                    print(error)
                 }
                completionHandler()
            }.resume()
        }
    }
    func movingAverage(window: Int,completionHandler: @escaping () -> Void){
        guard let cotacao = cotacao else { return }
        for index in (window..<cotacao.count){
            self.mediaMovelCotacao.append(cotacao[(index-window)...(index)].reduce(0, { $0+(Double($1.fec) ?? 0.0) }) / Double(window) )
        }
        completionHandler()
    }
    func gerateTrens(completionHandler: @escaping () -> Void){
        let lastIndex = mediaMovelCotacao.count-1
        trends.forEach({ key,value in
            trends[key] = (mediaMovelCotacao[lastIndex-key] - mediaMovelCotacao[lastIndex] ) / Double(key)
        })
        completionHandler()
    }
    
    
}

