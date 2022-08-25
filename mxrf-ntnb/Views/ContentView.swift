//
//  ContentView.swift
//  mxrf-ntnb
//
//  Created by Giordano Mattiello on 22/08/22.
//

import SwiftUI


struct ContentView: View {
    let mxrfMLModel:MxrfMLModel = MxrfMLModel()
    @StateObject var ntnbManager = NTNBManager()
    @StateObject var cotacaoManager = CotacaoManager()
    
    @State var texto:String = "Carregando"
    @State var description:String = ""
    @State private var opacity: Double = 1
    
    
    var body: some View {
        VStack{
            Spacer()
            Text("MXRF11 ♥︎")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
                .foregroundColor(.red)
            Text(description)
                .padding()
                .frame(height: 100)
                .opacity(opacity)
            if(ntnbManager.allDataReady && cotacaoManager.allDataReady){
                Chart(movingAverage: cotacaoManager.mediaMovelCotacao)
                    .padding()
                    .frame(height: 300)
                Spacer()
                Button("Refresh"){
                    ntnbManager.allDataReady = false
                    cotacaoManager.allDataReady = false
                    loadData()
                }
            }else {
                LoadingView()
            }
            Spacer()
        }.onAppear(){
            loadData()
        }
    }
    
    func loadData(){
        changeDescription(text: "Nossos robos estão coletando dados para fazer uma previsão")
        ntnbManager.configure(){
            getModelPrediction()
        }
        cotacaoManager.configure {
            getModelPrediction()
        }

    }
    func getModelPrediction(){
        if(!ntnbManager.allDataReady || !cotacaoManager.allDataReady){
            return
        }
        let input = MXRFANDNTNBModelInput(
             Cotacao: cotacaoManager.ultimaCotacao,
             Cotacao_AVG_30: cotacaoManager.ultimaMediaMovel,
             B_Trend_15: ntnbManager.trends[15] ?? 0.0,
             B_Trend_30: ntnbManager.trends[30] ?? 0.0,
             B_Trend_120: ntnbManager.trends[120] ?? 0.0, 
             NTN_B_AVG_30: ntnbManager.ultimaMediaMovel,
             Cot_Trend_15: cotacaoManager.trends[15] ?? 0.0,
             Cot_Trend_30: cotacaoManager.trends[30] ?? 0.0,
             Cot_Trend_120: cotacaoManager.trends[120] ?? 0.0
         )
         let output = mxrfMLModel.predict(input: input)
         if output {
             changeDescription(text: "Estamos em têndencia de subida, pode manter sua posição em MXRF11 ♥︎")
         } else {
             changeDescription(text: "Ah não 😞, os robos não temos certeza se vai continuar subindo. Reveja sua posição")
         }
        
    }
    func changeDescription(text: String){
        if self.description == ""{
            self.description = text
            return
        }
        withAnimation(.easeInOut(duration: 1), { self.opacity = 0 })
        self.description = text
        withAnimation(.easeInOut(duration: 1), { self.opacity = 1 })
    }
        
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
