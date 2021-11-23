//
//  StoreData.swift
//  birthday
//
//  Created by Yoav Paskaro on 21/11/2021.
//

import SwiftUI

// Store Data
func saveName(name: String) {
    UserDefaults.standard.set(name, forKey: birthdayNameKey)
}

func saveDate(date: Date) {
    UserDefaults.standard.set(date, forKey: birthdayDateKey)
}

func saveImage(babyUIImage: UIImage?) {
    // Convert to Data
    if let data = babyUIImage?.jpegData(compressionQuality: 1.0) {
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
            print("Unable to Write Image to Disk")
        }
    }
    else {
        print("Unable to Parse image to Data")
    }
}

// Restore Data
func loadName() -> String? {
    return UserDefaults.standard.value(forKey: birthdayNameKey) as? String
}

func loadDate() -> Date? {
    return UserDefaults.standard.value(forKey: birthdayDateKey) as? Date
}

func loadImage() -> UIImage? {
    if let urlStr = UserDefaults.standard.value(forKey: birthdayImageFileNameKey) {
        // Create URL
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent(urlStr as! String)
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        } else {
            print("load Image failed")
        }
    }
    return nil
}
