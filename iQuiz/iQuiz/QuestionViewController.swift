//
//  QuestionViewController.swift
//  iQuiz
//
//  Created by 郭家玮 on 5/12/25.
//

import UIKit

class QuestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    var selectedIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "💡 Swipe 👉 to Submit, 👈 to Quit"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        guard QuizManager.shared.currentQuiz != nil else {
            fatalError("No quiz selected")
        }
        loadQuestion()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
    }
    
    @objc func didSwipeRight() {
        submitTapped(submitButton)
    }
    
    @objc func didSwipeLeft() {
        let alert = UIAlertController(title: "Quit Quiz", message: "Are you sure you want to quit?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            QuizManager.shared.reset()
            self.navigationController?.popToRootViewController(animated: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func loadQuestion() {
        guard QuizManager.shared.currentIndex < QuizManager.shared.questions.count else { return }
        let question = QuizManager.shared.questions[QuizManager.shared.currentIndex]
        questionLabel.text = question.text
        selectedIndex = nil
        tableView.reloadData()
    }

    @IBAction func submitTapped(_ sender: UIButton) {
        guard let selected = selectedIndex else { return }
        QuizManager.shared.selectedIndex = selected
        let currentQuestion = QuizManager.shared.questions[QuizManager.shared.currentIndex]
        if selected == currentQuestion.correctIndex {
            QuizManager.shared.score += 1
        }
        performSegue(withIdentifier: "toAnswer", sender: self)
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let question = QuizManager.shared.questions[QuizManager.shared.currentIndex]
        return question.options.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell", for: indexPath)
        let question = QuizManager.shared.questions[QuizManager.shared.currentIndex]
        cell.textLabel?.text = question.options[indexPath.row]
        cell.accessoryType = indexPath.row == selectedIndex ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
}
