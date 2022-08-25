//
//  LoadingView.swift
//  mxrf-ntnb
//
//  Created by Giordano Mattiello on 24/08/22.
//

import SwiftUI

struct LoadingView: View {
    @State private var isLoading = false
    private let gradient = AngularGradient(
        gradient: Gradient(colors: [Color.red, .white]),
        center: .center,
        startAngle: .degrees(270),
        endAngle: .degrees(0))
    let durationCricularRotation:Double = 1.5

    var body: some View {
        ZStack{
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(gradient, lineWidth: 3)
                .frame(width: 100, height: 100)
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .animation(Animation.linear(duration: durationCricularRotation)
                    .repeatForever(autoreverses: false), value: isLoading)
                .onAppear() {
                    self.isLoading = true
                }
            Circle()
                .frame(width: 6, height: 6, alignment: .center)
                .foregroundColor(.red)
                .offset( y: -50)
                .rotationEffect(Angle(degrees: isLoading ? 360 : 0))
                .animation(Animation.linear(duration: durationCricularRotation)
                    .repeatForever(autoreverses: false), value: isLoading)
                .onAppear() {
                    self.isLoading = true
                }
        }

        
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
