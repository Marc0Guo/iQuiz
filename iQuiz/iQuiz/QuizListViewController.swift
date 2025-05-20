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
    let refreshControl = UIRefreshControl()

    var quizzes: [Quiz] {
        return QuizManager.shared.quizzes
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "iQuiz"
        tableView.delegate = self
        tableView.dataSource = self

        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        tableView.refreshControl = refreshControl

        NotificationCenter.default.addObserver(self, selector: #selector(reloadQuizData), name: Notification.Name("QuizDataUpdated"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        updateRefreshTimerAndFetch()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        refreshTimer?.invalidate()
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }

    @IBAction func settingsTapped(_ sender: UIBarButtonItem) {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
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

    @objc func appWillEnterForeground() {
        updateRefreshTimerAndFetch()
    }

    @objc func refreshData() {
        let url = UserDefaults.standard.string(forKey: "quizURL") ?? "http://tednewardsandbox.site44.com/questions.json"
        QuizManager.shared.fetchQuizData(from: url) { success in
            DispatchQueue.main.async {
                if success {
                    if !self.quizzes.isEmpty {
                        let source = QuizManager.shared.isConnectedToInternet() ? "network" : "local"
                        self.refreshControl.attributedTitle = NSAttributedString(string: "Last updated: \(Date().formatted()) (\(source))")
                    } else {
                        self.refreshControl.attributedTitle = NSAttributedString(string: "No quizzes available")
                    }
                } else {
                    self.refreshControl.attributedTitle = NSAttributedString(string: "Failed to load quizzes")
                }
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }

    func updateRefreshTimerAndFetch() {
        refreshTimer?.invalidate()
        let url = UserDefaults.standard.string(forKey: "quizURL") ?? "http://tednewardsandbox.site44.com/questions.json"
        let interval = UserDefaults.standard.double(forKey: "refreshInterval")
        QuizManager.shared.fetchQuizData(from: url) { success in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
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
}
