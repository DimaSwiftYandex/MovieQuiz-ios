//
//  QuestionFactory.swift
//  MovieQuiz
//
//  Created by Dmitry Dmitry on 16.10.2023.
//

import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private let moviesLoader: MoviesLoading
    weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    private var currentQuestionIndex: Int?

//    private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: "The Godfather",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Dark Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Kill Bill",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Avengers",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Deadpool",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Green Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Old",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Tesla",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Vivarium",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false)
//    ]
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.willLoadNextQuestion()
        }
        
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                //                print("Failed to load image")
                DispatchQueue.main.async {
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
            let rating = Float(movie.rating) ?? 0
            
            let text = "Рейтинг этого фильма больше чем 7?"
            let correctAnswer = rating > 7
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func reset() {
        currentQuestionIndex = nil
    }
}

