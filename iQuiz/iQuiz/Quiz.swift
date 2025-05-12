//
//  Quiz.swift
//  iQuiz
//
//  Created by 郭家玮 on 5/12/25.
//

import Foundation

struct Quiz {
    let title: String
    let questions: [Question]
}

struct Question {
    let text: String
    let options: [String]
    let correctIndex: Int
}

class QuizManager {
    static let shared = QuizManager()
    
    var currentQuiz: Quiz? {
        didSet {
            questions = currentQuiz?.questions ?? []
            reset()
        }
    }
    
    var questions: [Question] = []
    var currentIndex: Int = 0
    var selectedIndex: Int? = nil
    var score: Int = 0

    func reset() {
        currentIndex = 0
        selectedIndex = nil
        score = 0
    }
}
