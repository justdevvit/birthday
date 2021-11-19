//
//  ContentView.swift
//  birthday
//
//  Created by Yoav Paskaro on 15/11/2021.
//

import SwiftUI

struct BirthdayDetails {
    var name: String
    var years: Int
    var months: Int
    var babyUIImage: UIImage?
}

struct ContentView: View {
    private let birthdayImageFileName = "birthday.png"
    private let birthdayImageFileNameKey = "birthdayImageFileName"
    private let birthdayNameKey = "birthdayName"
    private let birthdayDateKey = "birthdayDate"
    private let appText: String

    private var startDate: Date?
    private var endDate: Date?
    
    @State private var birthdayDetails: BirthdayDetails = BirthdayDetails(name: "", years: 0, months: 0)
    @State private var name: String = ""
    @State private var date = Date.distantFuture
    @State private var shouldShowImagePicker = false
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var shouldShowBirthdayScreen = false
    
    init() {
        appText = "Happy Birthday!"
        restoreData()
        updateDatePickerRange()
    }
    
    var appNameView: some View {
        Text(appText)
    }
    
    var nameView: some View {
        TextField("Please type in the baby name", text:$name)
            .padding(.bottom)
            .multilineTextAlignment(TextAlignment.center)
            .onChange(of: name) {newValue in
                saveName()
            }
    }
    
    var datePickerTitleView: some View {
        Text("Please update Birthday:")
    }
    
    var datePickerView: some View {
        DatePicker("", selection: $date,  in: (startDate ?? Date())...(endDate ?? Date()), displayedComponents: .date)
            .padding(.bottom)
            .datePickerStyle(GraphicalDatePickerStyle())
            .onChange(of: date) {newValue in
                saveDate()
            }
    }
    
    var uploadPictureButtonView: some View {
        Button("Tap to upload a picture", action: {
            shouldShowImagePicker = true
        })
    }
    
    var imageView: some View {
        image?.resizable().scaledToFill().clipped()
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
                    imageView
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
        .sheet(isPresented: $shouldShowImagePicker, onDismiss: imageSelected) {
                ImagePicker(image: $inputImage)
        }
    }
    
    // baby period is until 3 age old, so we limit the birthday to 3 years ago max
    mutating func updateDatePickerRange() {
        let oneDayInSec: TimeInterval = 86400
        let oneYearInSec: TimeInterval = oneDayInSec * 365 // add one more day so 3 year old will be included in the range and won't be out of boundaries
        let birthdateRange = oneYearInSec * 3 + oneDayInSec
        endDate = Date()
        startDate = endDate?.addingTimeInterval(-birthdateRange)
    }
    
    func showBirthdayScreen() {
        let today = Date()
        let age = Calendar.current.dateComponents([.year, .month, .day], from: date, to: today)
        shouldShowBirthdayScreen = true
        birthdayDetails = BirthdayDetails(name: name, years: age.year ?? 0, months: age.month ?? 0, babyUIImage: inputImage)
    }
    
    func imageSelected() {
        displayImage()
        saveImage()
    }
    
    func displayImage() {
        guard let wrappedInputImage = inputImage else {
            return
        }
        image = Image(uiImage: wrappedInputImage)
    }
    
    // Store Data
    func saveName() {
        UserDefaults.standard.set(name, forKey: birthdayNameKey)
    }
    
    func saveDate() {
        UserDefaults.standard.set(date, forKey: birthdayDateKey)
    }
    
    func saveImage() {
        // Convert to Data
        if let data = inputImage?.jpegData(compressionQuality: 1.0) {
            // Create URL
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent(birthdayImageFileName)
            
            // Write to Disk
            if (try? data.write(to: url)) != nil {
                // Store image name in User Defaults
                UserDefaults.standard.set(birthdayImageFileName, forKey: birthdayImageFileNameKey)
                print("image saved")
            }
            else {
                print("Unable to Write Data to Disk")
            }
        }
        else {
            print("Unable to Parse image to Data")
        }
    }

    // Restore Data
    mutating func restoreData() {
        loadName()
        loadDate()
        loadImage()
    }
    
    mutating func loadName() {
        if let name: String = UserDefaults.standard.value(forKey: birthdayNameKey) as? String {
            _name = State(initialValue: name)
        } else {
            print("load name failed")
        }
    }
    
    mutating func loadDate() {
        if let date: Date = UserDefaults.standard.value(forKey: birthdayDateKey) as? Date {
            _date = State(initialValue: date)
        } else {
            print("load date failed")
        }
    }
    
    mutating func loadImage() {
        if let urlStr = UserDefaults.standard.value(forKey: birthdayImageFileNameKey) {
            // Create URL
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let url = documents.appendingPathComponent(urlStr as! String)
            if let data = try? Data(contentsOf: url) {
                _inputImage = State(initialValue:UIImage(data: data))
                _image =  State(initialValue:Image(uiImage: inputImage!))
            } else {
                print("load Image failed")
            }
        }
    }
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
