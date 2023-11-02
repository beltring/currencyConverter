//
//  UIViewController+Alert.swift
//  CurrencyConverter
//
//  Created by Pavel Boltromyuk on 2.11.23.
//

import UIKit

extension UIViewController {
    func presentAlert(title: String? = nil,
                      message: String? = nil,
                      preferredStyle: UIAlertController.Style = .alert,
                      cancelTitle: String = "Cancel",
                      cancelStyle: UIAlertAction.Style = .cancel,
                      cancelHandler: ((UIAlertAction) -> Void)? = nil,
                      otherActions: [UIAlertAction]? = nil,
                      animated: Bool = true,
                      completion: (() -> Void)? = nil) {
        
        DispatchQueue.main.async { [weak self] in
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            
            alert.addAction(UIAlertAction(title: cancelTitle, style: cancelStyle, handler: cancelHandler))
            otherActions?.forEach { alert.addAction($0) }
            
            self?.present(alert, animated: animated, completion: completion)
        }
    }
}
