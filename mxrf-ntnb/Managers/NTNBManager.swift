//
//  NTNBManager.swift
//  mxrf-ntnb
//
//  Created by Giordano Mattiello on 22/08/22.
//

import Foundation
import CSVImporter
 
class NTNBManager: ObservableObject {
    let userDefaults = UserDefaults.standard
    let dataBaseURL = "https://www.tesourotransparente.gov.br/ckan/dataset/df56aa42-484a-4a59-8184-7676580c81e3/resource/796d2059-14e9-44e3-80c9-2d9e30b405c1/download/PrecoTaxaTesouroDireto.csv"
    var titulos: [NTNBModel] = []
    var mediaMovelTitulos:[Double] = []
    var trends:[Int:Double] = [15:0.0 ,30:0.0, 120:0.0]
    var ultimaMediaMovel:Double = 0.0
    @Published var allDataReady: Bool = false
    @Published var outputString: String = ""
    
    func configure(completionHandler: @escaping () -> Void){
        self.downloadDataBase(){
            self.extractFromCSV(lastDays: 250) {
                self.movingAverage(window: 30, titulos: self.titulos) {
                    self.gerateTrens {
                        self.outputString = "Tudo Calculado"
                        self.allDataReady = true
                        self.ultimaMediaMovel = self.mediaMovelTitulos.last ?? 0.0
                        completionHandler()
                    }
                }
            }
        }
    }

    func downloadDataBase(completionHandler: @escaping () -> Void){
        if dataBaseAlreadyUpdateToday() {
            completionHandler()
            return
        }

        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = documentsUrl.appendingPathComponent("databaseNTNB.csv")
        guard let url = URL(string: dataBaseURL) else { return }
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
     
        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    self.outputString = "Base de dados atualizada com sucesso"
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                do {
                    if(FileManager.default.fileExists(atPath: destinationFileUrl.path)){
                        try FileManager.default.removeItem(atPath: destinationFileUrl.path)
                    }
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                    self.dataBaseUpdate()
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "No description");
            }
            completionHandler()
        }
        task.resume()
    }
    func extractFromCSV(lastDays: Double,completionHandler: @escaping () -> Void){
        self.outputString = "Importando dados macroeconomicos"
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = documentsUrl.appendingPathComponent("databaseNTNB.csv")
        let path = destinationFileUrl.path
        let importer = CSVImporter<[String]>(path: path,delimiter: ";")
        self.outputString = "Selecionando os dados mais importantes"
        importer.startImportingRecords { $0 }.onFinish { importedRecords in
            let filteredCsv:[NTNBModel] = importedRecords.compactMap({ record in
                if(record[0] == "Tesouro IPCA+" && self.isOnDateRange(lastDays: lastDays, stringDate: record[2])) {
                    return NTNBModel(dueDate: record[1], date: record[2], tax: record[3])
                }
                return nil
            })
            self.titulos = self.onlyLongestDueDate(titulos: filteredCsv)
            self.titulos.sort(by: { $0.date <  $1.date })
            self.outputString = "Dados prontos para analize"
            completionHandler()
        }
    }
    func dataBaseAlreadyUpdateToday() -> Bool{
        let lastDate =  userDefaults.string(forKey: "ntnbDataBaseLastDownloadDate")
        print(lastDate == todayString() ? "Database already update today " : "Database not update today")
        return lastDate == todayString()
    }
    func dataBaseUpdate(){
        userDefaults.set(todayString(), forKey: "ntnbDataBaseLastDownloadDate")
    }
    func todayString() -> String{
        let today = Date.now
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .short
        return formatter1.string(from: today)
    }
    
    func isOnDateRange(lastDays: Double,stringDate: String) -> Bool{
        let today = Date.now
        let date = Date.stringToDatePTBR(stringDate)
        let days = DateInterval.init(start: date, end: today).duration.days
        return days < lastDays
    }
    
    func onlyLongestDueDate(titulos: [NTNBModel]) -> [NTNBModel] {
        var newTitulos:[NTNBModel] = []
        for titulo in titulos {
            if let index = newTitulos.firstIndex(where: {$0.date == titulo.date}) {
                if( newTitulos[index].dueDate < titulo.dueDate ){
                    newTitulos[index] = titulo
                }
            } else {
                newTitulos.append(titulo)
            }
        }
        return newTitulos
    }
    func movingAverage(window: Int,titulos: [NTNBModel],completionHandler: @escaping () -> Void){
        var movingAverage:[Double] = []
        for index in (window..<titulos.count){
            movingAverage.append(titulos[(index-window)...(index)].reduce(0, { $0+$1.tax }) / Double(window) )
        }
        self.mediaMovelTitulos = movingAverage
        self.outputString = "Preparando para calcular tendências"
        completionHandler()
    }
    func gerateTrens(completionHandler: @escaping () -> Void){
        let lastIndex = mediaMovelTitulos.count-1
        trends.forEach({ key,value in
            trends[key] = (mediaMovelTitulos[lastIndex-key] - mediaMovelTitulos[lastIndex] ) / Double(key)
        })
        self.outputString = "Calculando tendências"
        completionHandler()
    }

    
    
}



