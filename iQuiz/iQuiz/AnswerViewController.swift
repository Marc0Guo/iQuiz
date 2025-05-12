//
//  AnswerViewController.swift
//  iQuiz
//
//  Created by 郭家玮 on 5/12/25.
//

import UIKit

class AnswerViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var resultLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard QuizManager.shared.currentIndex < QuizManager.shared.questions.count else {
            questionLabel.text = "No question"
            answerLabel.text = ""
            resultLabel.text = ""
            return
        }

        let question = QuizManager.shared.questions[QuizManager.shared.currentIndex]
        let selected = QuizManager.shared.selectedIndex ?? -1
        
        questionLabel.text = question.text
        answerLabel.text = "Answer: \(question.options[question.correctIndex])"
        resultLabel.text = selected == question.correctIndex ? "✅ Correct!" : "❌ Wrong!"
        resultLabel.textColor = selected == question.correctIndex ? .systemGreen : .systemRed
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        if QuizManager.shared.currentIndex + 1 < QuizManager.shared.questions.count {
            QuizManager.shared.currentIndex += 1
            performSegue(withIdentifier: "toQuestion", sender: self)
        } else {
            performSegue(withIdentifier: "toFinish", sender: self)
        }
    }
}

