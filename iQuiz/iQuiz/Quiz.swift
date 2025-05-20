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

    // Get the URL for the local quizzes file
    func getLocalQuizzesURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("quizzes.json")
    }

    // Save quizzes to local storage
    func saveQuizzesToLocal(_ quizzes: [Quiz]) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted // Make the JSON file human-readable
        if let data = try? encoder.encode(quizzes) {
            let url = getLocalQuizzesURL()
            do {
                try data.write(to: url)
                print("Saved quizzes to: \(url.path)")
            } catch {
                print("Failed to write quizzes: \(error)")
            }
        }
    }

    // Load quizzes from local storage
    func loadQuizzesFromLocal() -> [Quiz]? {
        let url = getLocalQuizzesURL()
        guard let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode([Quiz].self, from: data)
    }

    // Check if device is connected to internet
    func isConnectedToInternet() -> Bool {
        guard let url = URL(string: "https://www.apple.com") else { return false }
        let semaphore = DispatchSemaphore(value: 0)
        var isConnected = false

        let task = URLSession.shared.dataTask(with: url) { _, response, error in
            isConnected = (error == nil)
            semaphore.signal()
        }
        task.resume()
        semaphore.wait()
        return isConnected
    }

    // Fetch quiz data with offline support
    func fetchQuizData(from urlString: String, completion: @escaping (Bool) -> Void) {
        // First check internet connection
        if isConnectedToInternet() {
            // If connected, fetch from URL
            guard let url = URL(string: urlString) else {
                completion(false)
                return
            }

            let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }

                if let data = data {
                    let decoder = JSONDecoder()
                    if let quizzes = try? decoder.decode([Quiz].self, from: data) {
                        self.quizzes = quizzes
                        self.saveQuizzesToLocal(quizzes)
                        completion(true)
                        return
                    }
                }

                // If network request fails, try local data
                if let localQuizzes = self.loadQuizzesFromLocal() {
                    self.quizzes = localQuizzes
                    completion(true)
                } else {
                    completion(false)
                }
            }
            task.resume()
        } else {
            // If not connected, use local data
            if let localQuizzes = loadQuizzesFromLocal() {
                self.quizzes = localQuizzes
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}


