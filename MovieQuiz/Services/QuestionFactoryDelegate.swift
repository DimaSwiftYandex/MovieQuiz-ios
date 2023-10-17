//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Dmitry Dmitry on 16.10.2023.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
