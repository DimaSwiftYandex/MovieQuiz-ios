import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - IB Outlets
    @IBOutlet weak private var posterimageView: UIImageView!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    private var presenter: MovieQuizPresenter!
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        posterimageView.layer.cornerRadius = 20
        presenter.startGame()
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonTapped(_ sender: UIButton) {
        presenter.yesButtonTapped()
    }
    
    @IBAction private func noButtonTapped(_ sender: UIButton) {
        presenter.noButtonTapped()
    }

    // MARK: - Public functions
    
    func show(quiz step: QuizStepViewModel) {
        posterimageView.layer.borderColor = UIColor.clear.cgColor
        posterimageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                self?.presenter.restartGame()
            }
        )
        AlertPresenter(viewController: self).presentAlert(alertModel: alertModel)
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        posterimageView.layer.masksToBounds = true
        posterimageView.layer.borderWidth = 8
        posterimageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }

    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
        }
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] in
                self?.presenter.restartGame()
            }
        )
        AlertPresenter(viewController: self).presentAlert(alertModel: alertModel)
    }
    
    func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
}

