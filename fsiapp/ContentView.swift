//
//  ContentView.swift
//  fsiapp
//
//  Created by Mark Szulc on 25/2/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
          Color.orange
          .edgesIgnoringSafeArea(.all)
        
        VStack(alignment: .leading, spacing: 40, content: {
            
            Image("SecurBankLogoReverse")
                .resizable()
                .frame(width: 273, height: 50)
                .padding(.top, -60)
                .padding(.bottom, 0)
            
            
            offerlist()

        }).padding(.horizontal, 0)
        .padding(.leading, 20)
        }.accentColor(Color.white)
    }
}
        

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
