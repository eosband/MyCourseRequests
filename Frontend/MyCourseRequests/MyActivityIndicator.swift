//
//  MyActivityIndicator.swift
//  Memories
//
//  Created by Eric on 5/2/19.
//  Copyright © 2019 Chris Ward. All rights reserved.
//

import UIKit

import Foundation


class MyActivityIndicator {
    
    static var activityIndicatorObj = UIActivityIndicatorView()
    static var strLabel = UILabel()
    static let loadingAnimationView = UIView()
    
    static func activityIndicator(title: String, view: UIView) {
        strLabel.removeFromSuperview()
        activityIndicatorObj.removeFromSuperview()
        loadingAnimationView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 200, height: 46))
        strLabel.text = title
        strLabel.font = .systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        loadingAnimationView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 200, height: 46)
        loadingAnimationView.layer.cornerRadius = 15
        loadingAnimationView.backgroundColor = UIColor(red:0.27, green:0.27, blue:0.27, alpha:0.7)
        
        activityIndicatorObj = UIActivityIndicatorView(style: .white)
        activityIndicatorObj.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicatorObj.startAnimating()
        
        loadingAnimationView.addSubview(activityIndicatorObj)
        loadingAnimationView.addSubview(strLabel)
        view.addSubview(loadingAnimationView)
    }
    
    static func removeAll() {
        activityIndicatorObj.removeFromSuperview()
        strLabel.removeFromSuperview()
        loadingAnimationView.removeFromSuperview()
    }
    
}
