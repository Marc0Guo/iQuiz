//
//  QuizListViewController.swift
//  iQuiz
//
//  Created by 郭家玮 on 5/4/25.
//

import UIKit

class QuizListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    let quizzes = [
        ("Mathematics", "Math 127", "math_icon"),
        ("Marvel Super Heroes", "Marv 311", "marvel_icon"),
        ("Science", "Sci 288", "science_icon")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "iQuiz"
        tableView.delegate = self
        tableView.dataSource = self
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
        let (title, description, iconName) = quizzes[indexPath.row]
        cell.titleLabel.text = title
        cell.descriptionLabel.text = description
        cell.quizImageView.image = UIImage(named: iconName)
        return cell
    }
}
