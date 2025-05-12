//
//  FinishViewController.swift
//  iQuiz
//
//  Created by 郭家玮 on 5/12/25.
//

import UIKit

class FinishViewController: UIViewController {
    
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Quiz Complete!"
        let total = QuizManager.shared.questions.count
        let score = QuizManager.shared.score

        guard total > 0 else {
            summaryLabel.text = "No questions found."
            scoreLabel.text = "Score: 0 / 0"
            return
        }

        switch score {
        case total:
            summaryLabel.text = "🎉 Perfect!"
        case (total - 1):
            summaryLabel.text = "😄 Almost there!"
        default:
            summaryLabel.text = "📚 Keep Practicing!"
        }

        scoreLabel.text = "Score: \(score) / \(total)"
    }

    @IBAction func finishTapped(_ sender: UIButton) {
        QuizManager.shared.reset()
        navigationController?.popToRootViewController(animated: true)
    }
}
