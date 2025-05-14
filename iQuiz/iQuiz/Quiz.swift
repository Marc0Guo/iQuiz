//
//  Quiz.swift
//  iQuiz
//
//  Created by 郭家玮 on 5/12/25.
//

import Foundation

struct Quiz: Codable {
    let title: String
    let desc: String
    let questions: [Question]
    
    var iconName: String? {
        switch title {
        case "Mathematics": return "math_icon"
        case "Science!": return "science_icon"
        case "Marvel Super Heroes": return "marvel_icon"
        default: return "AppIcon"
        }
    }
}

struct Question: Codable {
    let text: String
    let answer: String
    let answers: [String]
    
    var correctIndex: Int? {
        return Int(answer)
    }
}

class QuizManager {
    static let shared = QuizManager()
    private init() {}

    var quizzes: [Quiz] = []
    var currentQuiz: Quiz?
    
    var currentQuestionIndex: Int = 0
    var selectedIndex: Int? = nil
    var score: Int = 0

    var questions: [Question] {
        return currentQuiz?.questions ?? []
    }
    
    func reset() {
        currentQuiz = nil
        currentQuestionIndex = 0
        score = 0
    }

    func fetchQuizData(from urlString: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            
            if let urlError = error as? URLError, urlError.code == .notConnectedToInternet {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: Notification.Name("NetworkUnavailable"), object: nil)
                }
                completion(false)
                return
            }
            
            guard let data = data, error == nil else {
                completion(false)
                return
            }

            do {
                let decoder = JSONDecoder()
                let quizzes = try decoder.decode([Quiz].self, from: data)
                self.quizzes = quizzes
                completion(true)
            } catch {
                print("JSON decode failed: \(error)")
                completion(false)
            }
        }.resume()
    }
}

