//
//  AppDelegate.swift
//  PropertyList APP
//
//  Created by Droisys on 26/08/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        UIFont.familyNames.forEach ({ name  in
            for font_name in UIFont.fontNames(forFamilyName: name){
                if font_name.lowercased().contains("roboto") {
                            print("Available: \(font_name)")
                        }
            }
            
        })
        setGlobalFont()
       // Override point for customization after application launch.
        return true
    }
    
    func setGlobalFont() {
        let fontName = "RobotoCondensed-Black"
        
        // For UILabel
        if let customFont = UIFont(name: fontName, size: 15) {
            UILabel.appearance().font = customFont
            print("✅ Label font set successfully: \(fontName)")
        } else {
            print("❌ Font name wrong: \(fontName)")
            // Available fonts print karo
            printRobotoFonts()
        }
        
        // For UIButton
        if let customFont = UIFont(name: fontName, size: 15) {
            UIButton.appearance().titleLabel?.font = customFont
            print("✅ Button font set successfully")
        } else {
            print("❌ Button font failed")
        }
        
        // For UITextView
        if let customFont = UIFont(name: fontName, size: 15) {
            UITextView.appearance().font = customFont
            print("✅ TextView font set")
        }
        
        // For UITextField
        if let customFont = UIFont(name: fontName, size: 15) {
            UITextField.appearance().font = customFont
            print("✅ TextField font set")
        }
    }

    func printRobotoFonts() {
        print("\n📝 Available Roboto fonts:")
        UIFont.familyNames.forEach { familyName in
            UIFont.fontNames(forFamilyName: familyName).forEach { fontName in
                if fontName.lowercased().contains("roboto") {
                    print("  • \(fontName)")
                }
            }
        }
    }
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

