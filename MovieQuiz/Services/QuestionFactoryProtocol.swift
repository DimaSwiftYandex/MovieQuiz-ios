//
//  QuestionFactoryProtocol.swift
//  MovieQuiz
//
//  Created by Dmitry Dmitry on 16.10.2023.
//

import Foundation

protocol QuestionFactoryProtocol {
    var delegate: QuestionFactoryDelegate? { get set }
    func loadData()
    func requestNextQuestion()
    func reset()
}

