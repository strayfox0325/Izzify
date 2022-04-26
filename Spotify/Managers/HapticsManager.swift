//
//  HapticsManager.swift
//  Spotify
//
//  Created by Isidora Lazic on 30.1.22..
//

import Foundation
import UIKit

final class HapticsManager{
    
    // MARK: - Singleton
    
    static let shared = HapticsManager()
    
    // MARK: - Init
    
    private init(){}
    
    // MARK: - Helpers
    
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
