//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Dmitry Dmitry on 16.10.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: () -> ()
}
