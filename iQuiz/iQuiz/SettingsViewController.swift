//
//  SettingsViewController.swift
//  iQuiz
//
//  Created by 郭家玮 on 5/13/25.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var intervalSlider: UISlider!
    @IBOutlet weak var intervalLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showNetworkError), name: Notification.Name("NetworkUnavailable"), object: nil)
        
        self.title = "Settings"
        
        let defaultURL = "http://tednewardsandbox.site44.com/questions.json"
        let savedURL = UserDefaults.standard.string(forKey: "quizURL") ?? defaultURL
        urlField.text = savedURL
        
        let savedInterval = UserDefaults.standard.double(forKey: "refreshInterval")
        intervalSlider.value = savedInterval > 0 ? Float(savedInterval) : 60
        intervalLabel.text = "Refresh every \(Int(intervalSlider.value))s"
    }
    
    @objc func showNetworkError() {
        let alert = UIAlertController(title: "Network Error", message: "You're not connected to the internet. Please check your connection.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func checkNowTapped(_ sender: UIButton) {
        
        let interval = Double(Int(intervalSlider.value))
        UserDefaults.standard.set(interval, forKey: "refreshInterval")
        
        guard let urlString = urlField.text, !urlString.isEmpty else {
            statusLabel.text = "Please enter a valid URL."
            statusLabel.textColor = .systemRed
            return
        }

        UserDefaults.standard.set(urlString, forKey: "quizURL")

        QuizManager.shared.fetchQuizData(from: urlString) { success in
            DispatchQueue.main.async {
                if success {
                    self.statusLabel.text = "✅ Quizzes downloaded!"
                    self.statusLabel.textColor = .systemGreen
                    
                    NotificationCenter.default.post(name: Notification.Name("QuizDataUpdated"), object: nil)
                } else {
                    self.statusLabel.text = "❌ Failed to download quizzes."
                    self.statusLabel.textColor = .systemRed
                }
            }
        }
    }
    
    @IBAction func intervalSliderChanged(_ sender: UISlider) {
        let interval = Int(sender.value)
        intervalLabel.text = "Refresh every \(interval)s"
    }
    
}
