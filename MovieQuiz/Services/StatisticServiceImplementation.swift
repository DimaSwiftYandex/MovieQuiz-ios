//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Dmitry Dmitry on 17.10.2023.
//

import UIKit

final class StatisticServiceImplementation: StatisticService {
    
    private enum Keys: String {
        case gamesCount, totalCorrect, bestGame
    }
    
    private let userDefaults = UserDefaults.standard

    var gamesCount: Int {
        get { userDefaults.integer(forKey: Keys.gamesCount.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue) }
    }
    
    private var totalCorrect: Int {
        get { userDefaults.integer(forKey: Keys.totalCorrect.rawValue) }
        set { userDefaults.set(newValue, forKey: Keys.totalCorrect.rawValue) }
    }
    
    var bestGame: GameRecord {
        get {
            if let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
               let record = try? JSONDecoder().decode(GameRecord.self, from: data) {
                return record
            }
            return GameRecord(correct: 0, total: 0, date: Date())
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                userDefaults.set(data, forKey: Keys.bestGame.rawValue)
            }
        }
    }
    
    var totalAccuracy: Double {
        gamesCount == 0 ? 0 : Double(totalCorrect) / Double(gamesCount * 10)
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        totalCorrect += count
        
        let newGame = GameRecord(correct: count, total: amount, date: Date())
        if newGame.isBetterThan(bestGame) {
            bestGame = newGame
        }
    }
}
