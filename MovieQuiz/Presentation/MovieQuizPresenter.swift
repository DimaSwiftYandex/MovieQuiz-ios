//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Dmitry Dmitry on 19.11.2023.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func setButtonsEnabled(_ isEnabled: Bool)
}

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    private let statisticService: StatisticService
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?

    private var currentQuestion: QuizQuestion?
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0

    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        self.statisticService = StatisticServiceImplementation()
        self.questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        self.questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }

    // MARK: - QuestionFactoryDelegate

    func didLoadDataFromServer() {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.questionFactory?.requestNextQuestion()
        }
    }
    
    func didFailToLoadData(with error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.hideLoadingIndicator()
            self?.viewController?.showNetworkError(message: error.localizedDescription)
        }
    }

    func didReceiveNextQuestion(question: QuizQuestion?) {
        viewController?.setButtonsEnabled(true)
        guard let question = question else {
            finishGame()
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func willLoadNextQuestion() {
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.showLoadingIndicator()
        }
    }

    private func finishGame() {
        let result = QuizResultsViewModel(
            title: "Этот раунд окончен!",
            text: makeResultsMessage(),
            buttonText: "Сыграть ещё раз"
        )
        viewController?.show(quiz: result)
    }

    func yesButtonTapped() {
        viewController?.setButtonsEnabled(false)
        didAnswer(isYes: true)
    }
    
    func noButtonTapped() {
        viewController?.setButtonsEnabled(false)
        didAnswer(isYes: false)
    }
    
    func startGame() {
        viewController?.showLoadingIndicator()
        questionFactory?.loadData()
    }

    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }

        let isCorrect = (isYes == currentQuestion.correctAnswer)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        if isCorrect {
            correctAnswers += 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.proceedToNextQuestionOrResults()
        }
    }

    private func proceedToNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            finishGame()
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    func restartGame() {
        DispatchQueue.main.async { [weak self] in
            self?.currentQuestionIndex = 0
            self?.correctAnswers = 0
            self?.questionFactory?.reset()
            self?.viewController?.showLoadingIndicator()
            self?.questionFactory?.requestNextQuestion()
        }
    }

    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    private func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)

        let bestGame = statisticService.bestGame
        let totalPlaysCountLine = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        let currentGameResultLine = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))"
        let averageAccuracyLine = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%"

        return [currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine].joined(separator: "\n")
    }
}



