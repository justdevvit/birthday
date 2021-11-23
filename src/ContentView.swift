//
//  ContentView.swift
//  birthday
//
//  Created by Yoav Paskaro on 15/11/2021.
//

import SwiftUI

class BirthdayDetails: ObservableObject {
    @Published var name = ""
    @Published var years = 0
    @Published var months = 0
    @Published var babyUIImage: UIImage?
    @Published var babyImage: Image?
    @Published var ABCresult = 0
}

struct ContentView: View {
    private let appText: String = "Happy Birthday!"
    private let endDate = Date()

    @StateObject private var birthdayDetails = BirthdayDetails()
    @State private var name = ""
    @State private var date = Date.distantFuture
    @State private var shouldShowImagePicker = false
    @State private var shouldShowActionScheet = false
    @State private var shouldShowCamera = false
    @State private var didCancelImagePicker = false
    @State private var babyUIImage: UIImage?
    @State private var shouldShowBirthdayScreen = false
    @State private var startDate = Date.distantPast
    @State private var ABCresult = 0

    var appNameView: some View {
        Text(appText)
    }
    
    var nameView: some View {
        TextField("Please type in the baby name", text:$name)
            .padding(.bottom)
            .multilineTextAlignment(TextAlignment.center)
            .onChange(of: name) {newValue in
                saveName(name: newValue)
            }
    }
    
    var datePickerTitleView: some View {
        Text("Please update Birthday:")
    }
    
    var datePickerView: some View {
        DatePicker("", selection: $date,  in: (startDate...endDate), displayedComponents: .date)
            .padding(.bottom)
            .datePickerStyle(GraphicalDatePickerStyle())
            .onChange(of: date) {newValue in
                saveDate(date: newValue)
            }
            .onAppear {
                updateDatePickerRange()
            }
    }
    
    var uploadPictureButtonView: some View {
        Button("Tap to upload a picture", action: {
            shouldShowActionScheet = true
        })
    }
    
    var babyImageView: some View {
        birthdayDetails.babyImage?
            .resizable()
            .scaledToFill()
            .clipped()
    }
    
    var showBirthdayScreenButtonView: some View {
        Button("Show birthday screen", action: showBirthdayScreen)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing:0) {
                    Spacer()
                    Divider()
                    appNameView
                        .padding(.vertical)
                    nameView
                    datePickerTitleView
                    datePickerView
                    uploadPictureButtonView
                    babyImageView
                    showBirthdayScreenButtonView
                        .padding(.vertical)
                        .disabled(name.isEmpty || date == Date.distantFuture)
                    
                    NavigationLink(
                                destination: birthdayScreenView(birthdayDetails: birthdayDetails),
                                isActive: $shouldShowBirthdayScreen
                            ) {
                    }
                }
                .navigationBarHidden(true)
            }
        }
        .actionSheet(isPresented: $shouldShowActionScheet) { () -> ActionSheet in
            ActionSheet(title: Text("Please choose mode"), buttons: [ActionSheet.Button.default(Text("Camera"), action: {
                shouldShowImagePicker = true
                shouldShowCamera = true
            }), ActionSheet.Button.default(Text("Photo Library"), action: {
                shouldShowImagePicker = true
                shouldShowCamera = false
            }), ActionSheet.Button.cancel()])
        }
        .sheet(isPresented: $shouldShowImagePicker, onDismiss: imageSelected) {
            ImagePickerView(sourceType: shouldShowCamera ? .camera : .photoLibrary, image: $babyUIImage, isPresented: $shouldShowImagePicker, didCancel: $didCancelImagePicker)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear(perform: {
            restoreData()
        })
    }
    
    // baby period is until 3 age old, so we limit the birthday to 3 years ago max
    func updateDatePickerRange() {
        let oneDayInSec: TimeInterval = 86400
        let oneYearInSec: TimeInterval = oneDayInSec * 365 // add one more day so 3 year old will be included in the range and won't be out of boundaries
        let birthdateRange = oneYearInSec * 3 + oneDayInSec
        startDate = endDate.addingTimeInterval(-birthdateRange)
    }
    
    func showBirthdayScreen() {
        let today = Date()
        let age = Calendar.current.dateComponents([.year, .month, .day], from: date, to: today)
        shouldShowBirthdayScreen = true
        birthdayDetails.name = name
        birthdayDetails.years = age.year ?? 0
        birthdayDetails.months = age.month ?? 0
        calcABC()
    }
    
    func imageSelected() {
        if (didCancelImagePicker || babyUIImage == nil) {
            return
        }
        birthdayDetails.babyUIImage = babyUIImage
        displayBabyImage()
        saveImage(babyUIImage:birthdayDetails.babyUIImage)
    }
    
    func displayBabyImage() {
        guard let wrappedBabyUIImage = birthdayDetails.babyUIImage else {
            return
        }
        birthdayDetails.babyImage = Image(uiImage: wrappedBabyUIImage)
    }

    // Restore Data
    func restoreData() {
        restoreName()
        restoreDate()
        restoreImage()
    }
    
    func restoreName() {
        if let loadedName: String = loadName() {
            name = loadedName
        } else {
            print("load name failed")
        }
    }
    
    func restoreDate() {
        if let loadedDate: Date = loadDate() {
            date = loadedDate
        } else {
            print("load date failed")
        }
    }
    
    func restoreImage() {
        if let loadedImage: UIImage = loadImage() {
            birthdayDetails.babyUIImage = loadedImage
            displayBabyImage()
        }  else {
            print("load image failed")
        }
    }
    
    func calcABC() {
        let numbers = [0, 1, 2]
        birthdayDetails.ABCresult = numbers.randomElement() ?? 0
    }
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
