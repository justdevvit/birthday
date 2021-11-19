//
//  birthdayScreenView.swift
//  birthday
//
//  Created by Yoav Paskaro on 16/11/2021.
//

import SwiftUI

struct birthdayScreenView: View {
    var ageTextPrefix: String = ""
    var ageTextSuffix: String = ""
    var babyUIImage: UIImage?
    var babyImage: Image?
    var ageImage: Image?
    var cameraIconUIImage: UIImage?
    var cameraIconImage: Image?
    
    let backgroundImage: Image
    let leftSwirlsImage: Image
    let rightSwirlsImage: Image
    let nanitLogoImage: Image
    let shareButtonText: String
    let shareButtonImage: Image
    
    //  temporary limit baby image size due to cameraIconImage offest issue
    let babyImageWidth = 225.0
    let babyImageHeight = 225.0
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var birthdayDetails = BirthdayDetails(name: "", years: 0, months: 0)
    
    init(birthdayDetails: BirthdayDetails) {
        self.init()
        self.birthdayDetails = birthdayDetails
        
        let name = birthdayDetails.name
        self.ageTextPrefix = "TODAY " + name + " IS"
        var timeUnitsName: String
        var timeUnitsNumber: Int
        let years = birthdayDetails.years
        var months = birthdayDetails.months
        // for baby that was born this month we'll ceil to 1 month for display purpose (since there is no days resolution)
        if (years == 0 && months == 0) {
            months = 1
        }
        if (years == 0) {
            timeUnitsName = "MONTH"
            timeUnitsNumber = months
        } else {
            timeUnitsName = "YEAR"
            timeUnitsNumber =  years
        }
        self.ageTextSuffix = timeUnitsName + " OLD!"
        self.ageImage = Image(String(timeUnitsNumber))
        
        babyUIImage = birthdayDetails.babyUIImage ?? UIImage(named: "defaultPlaceHolderBlue")
        guard let wrappedbabyUIImage = babyUIImage else {
            return
        }
        babyImage = Image(uiImage: wrappedbabyUIImage)
    }
    
    init() {
        // TODO: implement ABC Test
        backgroundImage = Image("iOsBgElephant")
        leftSwirlsImage = Image("leftSwirls")
        rightSwirlsImage = Image("rightSwirls")
        nanitLogoImage = Image("nanitLogo")
        shareButtonText = "Share the news"
        shareButtonImage = Image("shareWhiteSmall")
        
        cameraIconUIImage = UIImage(named: "cameraIconBlue")
        cameraIconImage = Image(uiImage: cameraIconUIImage!)
    }
    
    var btnBack : some View {
        Button(action: {
        self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("arrowBackBlue")
        }
    }

    var ageTextSectionView: some View {
        VStack(spacing:0) {
            Text(ageTextPrefix)
                .frame(width: 226, height: 50, alignment: .center)
                .padding(.bottom, 13)
            HStack(spacing: 0) {
                leftSwirlsImage
                    .padding(.trailing, 22)
                ageImage
                    .padding(.trailing, 22)
                rightSwirlsImage
            }
            .padding(.bottom, 14)
            Text(ageTextSuffix)
                .frame(width: 226, height: 25, alignment: .center)
        }
    }
    
    var imgAndLogAndShareView: some View {
        VStack(spacing:0) {
            ZStack {
                babyImage?
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
                    .clipShape(Circle())
                    .clipped()
                    .frame(width: babyImageWidth, height: babyImageHeight, alignment: .center)
                cameraIconImage
                    .offset(x: cameraIconX(), y: cameraIconY())
            }
            .padding(.bottom, 15)
            .padding(.horizontal, 50)
            nanitLogoImage
                .padding(.bottom, 20)
            Button(action: share) {
                Text(shareButtonText)
                    .font(Fonts.regular)
                    .multilineTextAlignment(TextAlignment.trailing)
                    .foregroundColor(.white)
                    .padding(.leading, 21)
                    .padding(.vertical, 11)
                shareButtonImage.renderingMode(.original)
                    .padding(.trailing, 5)
            }
            .frame(width: 179, height: 42, alignment: .center)
            .background(Capsule().fill(Colors.blush))
            .padding(.bottom, 88)
        }
    }
    
    var spaceView: some View {
        VStack(spacing:0) {
            EmptyView()
        }
        .frame(minHeight: 20, maxHeight: .infinity)
    }
    
    var body: some View {
        GeometryReader { gr in
            ScrollView {
                ZStack {
                    backgroundImage
                        .resizable().scaledToFill().clipped()
                    VStack(spacing:0) {
                        Spacer()
                        Divider()
                        spaceView
                        ageTextSectionView
                        spaceView
                        imgAndLogAndShareView
                    }
                    .frame(minWidth: gr.size.width, minHeight: gr.size.height)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: btnBack)
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
    
    func cameraIconImageSize() -> CGSize {
        return cameraIconUIImage?.size ?? CGSize.zero
    }
    
    func cameraIconX() -> CGFloat {
        let cameraIconImageWidth = cameraIconImageSize().width
        return babyImageWidth/2 - cameraIconImageWidth/2
    }
    
    func cameraIconY() -> CGFloat {
        return -babyImageHeight/4
    }
    
    func share() {
        print("share")
    }
}

struct birthdayScreenView_Previews: PreviewProvider {
    static var previews: some View {
        birthdayScreenView()
    }
}
