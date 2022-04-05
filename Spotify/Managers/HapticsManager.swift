//
//  HapticsManager.swift
//  Spotify
//
//  Created by Isidora Lazic on 30.1.22..
//

import Foundation
import UIKit

final class HapticsManager{
    
    static let shared = HapticsManager()
    
    private init(){}
    
    public func vibrateForSelection(){
        DispatchQueue.main.async {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
    
    public func vibrate(for type: UINotificationFeedbackGenerator.FeedbackType){
        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(type)
        }
    }
}
