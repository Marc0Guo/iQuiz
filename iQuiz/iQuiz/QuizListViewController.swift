//
//  QuizListViewController.swift
//  iQuiz
//
//  Created by 郭家玮 on 5/4/25.
//

import UIKit

class QuizListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshTimer: Timer? 

    var quizzes: [Quiz] {
        return QuizManager.shared.quizzes
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "iQuiz"
        tableView.delegate = self
        tableView.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(reloadQuizData), name: Notification.Name("QuizDataUpdated"), object: nil)

        let url = UserDefaults.standard.string(forKey: "quizURL") ?? "http://tednewardsandbox.site44.com/questions.json"
        QuizManager.shared.fetchQuizData(from: url) { success in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        let interval = UserDefaults.standard.double(forKey: "refreshInterval")
        if interval > 0 {
            refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                let url = UserDefaults.standard.string(forKey: "quizURL") ?? "http://tednewardsandbox.site44.com/questions.json"
                QuizManager.shared.fetchQuizData(from: url) { _ in
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refreshTimer?.invalidate()
    }

    @IBAction func settingsTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Settings", message: "Settings go here", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizzes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "quizCell", for: indexPath) as! QuizCell
        let quiz = quizzes[indexPath.row]
        cell.titleLabel.text = quiz.title
        cell.descriptionLabel.text = quiz.desc
        cell.quizImageView.image = UIImage(named: quiz.iconName ?? "AppIcon")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toQuestion", sender: self)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toQuestion",
           let indexPath = tableView.indexPathForSelectedRow {
            
            let quiz = quizzes[indexPath.row]
            QuizManager.shared.currentQuiz = quiz
        }
    }
    
    @objc func reloadQuizData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    @objc func refreshData() {
        let url = UserDefaults.standard.string(forKey: "quizURL") ?? "http://tednewardsandbox.site44.com/questions.json"
        QuizManager.shared.fetchQuizData(from: url) { success in
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
}
