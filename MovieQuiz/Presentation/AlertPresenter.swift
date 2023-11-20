//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Dmitry Dmitry on 16.10.2023.
//

import UIKit

class AlertPresenter {
    
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func presentAlert(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        
        alert.view.accessibilityIdentifier = "Game results"
        
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default
        ) { _ in
            alertModel.completion()
        }
        
        alert.addAction(action)
        viewController?.present(alert, animated: true, completion: nil)
    }
}


