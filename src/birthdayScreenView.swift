//
//  birthdayScreenView.swift
//  birthday
//
//  Created by Yoav Paskaro on 16/11/2021.
//

import SwiftUI

struct birthdayScreenView: View {
    let backgroundImage: Image
    let ageTextPrefix: String
    let leftSwirlsImage: Image
    let ageImage: Image
    let rightSwirlsImage: Image
    let ageTextSuffix: String
    var babyUIImage: UIImage?
    var babyImage: Image?
    var cameraIconUIImage: UIImage?
    var cameraIconImage: Image?
    let nanitLogoImage: Image
    let shareButtonText: String
    let shareButtonImage: Image
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    init() {
        // TODO: implement ABC Test & age text,image logic
        backgroundImage = Image("iOsBgElephant")
        ageTextPrefix = "TODAY CRISTIANO RONALDO IS"
        ageTextSuffix = "MONTH OLD"
        ageImage = Image("1")

        leftSwirlsImage = Image("leftSwirls")
        rightSwirlsImage = Image("rightSwirls")
        nanitLogoImage = Image("nanitLogo")
        shareButtonText = "Share the news"
        shareButtonImage = Image("shareWhiteSmall")
        
        babyUIImage = UIImage(named: "defaultPlaceHolderBlue")
        guard let wrappedbabyUIImage = babyUIImage else {
            return
        }
        babyImage = Image(uiImage: wrappedbabyUIImage)
        
        cameraIconUIImage = UIImage(named: "cameraIconBlue")
        guard let wrappedCameraIconUIImage = cameraIconUIImage else {
            return
        }
        cameraIconImage = Image(uiImage: wrappedCameraIconUIImage)
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
                .padding(.bottom, 13)
            HStack(spacing: 0) {
                leftSwirlsImage
                ageImage
                rightSwirlsImage
            }
            .padding(.bottom, 14)
            Text(ageTextSuffix)
        }
    }
    
    var imgAndLogAndShareView: some View {
        VStack(spacing:0) {
            ZStack {
                babyImage?
                    .resizable().scaledToFill().clipped()
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
    
    func babyImageSize() -> CGSize {
        return babyUIImage?.size ?? CGSize.zero
    }
    
    func cameraIconImageSize() -> CGSize {
        return cameraIconUIImage?.size ?? CGSize.zero
    }
    
    func cameraIconX() -> CGFloat {
        let babyImageWidth = babyImageSize().width,
            cameraIconImageWidth = cameraIconImageSize().width
        return babyImageWidth/2 - cameraIconImageWidth/2
    }
    
    func cameraIconY() -> CGFloat {
        let babyImageHeight = babyImageSize().height
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
