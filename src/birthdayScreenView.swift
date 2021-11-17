//
//  birthdayScreenView.swift
//  birthday
//
//  Created by Yoav Paskaro on 16/11/2021.
//

import SwiftUI

struct birthdayScreenView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var btnBack : some View { Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("arrowBackBlue")
                .aspectRatio(contentMode: .fit)
        }
    }

    var body: some View {
        VStack {
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: btnBack)
    }
}

struct birthdayScreenView_Previews: PreviewProvider {
    static var previews: some View {
        birthdayScreenView()
    }
}
