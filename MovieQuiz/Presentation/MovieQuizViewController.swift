import UIKit

final class MovieQuizViewController: UIViewController {
    
    // MARK: - IB Outlets
    @IBOutlet weak private var posterimageView: UIImageView!
    @IBOutlet weak private var questionLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var yesButton: UIButton!
    
    // MARK: - Private Properties
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private var statisticService: StatisticService = StatisticServiceImplementation()
    
    private var questionFactory: QuestionFactoryProtocol? = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    private lazy var alertPresenter = AlertPresenter(viewController: self)
    private let questionsAmount: Int = 10
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        posterimageView.layer.cornerRadius = 20
        questionFactory?.delegate = self
        questionFactory?.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - IB Actions
    @IBAction private func yesButtonTapped(_ sender: UIButton) {
        setButtonsEnabled(false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        currentQuestion.correctAnswer
        ? showAnswerResult(isCorrect: true)
        : showAnswerResult(isCorrect: false)
    }
    
    @IBAction private func noButtonTapped(_ sender: UIButton) {
        setButtonsEnabled(false)
        guard let currentQuestion = currentQuestion else {
            return
        }
        currentQuestion.correctAnswer
        ? showAnswerResult(isCorrect: false)
        : showAnswerResult(isCorrect: true)
    }
    
    // MARK: - Private Methods
    private func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        posterimageView.layer.masksToBounds = true
        posterimageView.layer.borderWidth = 8
        posterimageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        if isCorrect {
            posterimageView.layer.borderColor = UIColor.ypGreen.cgColor
            correctAnswers += 1
        } else {
            posterimageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex += 1
            if self.currentQuestionIndex < self.questionsAmount {
                self.questionFactory?.requestNextQuestion()
            } else {
                self.finishGame()
            }
        }
    }
    
    private func finishGame() {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        showGameResults()
    }
    
    private func showGameResults() {
        let bestGameRecord = statisticService.bestGame
        let formattedDate = bestGameRecord.date.dateTimeString
        let message = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(bestGameRecord.correct)/\(bestGameRecord.total) (\(formattedDate))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%
            """
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: message,
            buttonText: "Сыграть ещё раз"
        ) { [weak self] in
            self?.restartQuiz()
        }
        alertPresenter.presentAlert(alertModel: alertModel)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel) {
        posterimageView.image = step.image
        questionLabel.text = step.question
        counterLabel.text = step.questionNumber
        
        posterimageView.layer.borderColor = UIColor.clear.cgColor
        
        setButtonsEnabled(true)
    }
    
//    private func showNextQuestionOrResults() {
//        if currentQuestionIndex == questionsAmount - 1 {
//            let text = "Ваш результат: \(correctAnswers)/10"
//            let quizResult = QuizResultsViewModel(
//                title: "Поздравляем, вы ответили на 10 из 10!",
//                text: text,
//                buttonText: "Сыграть ещё раз"
//            )
//            show(quiz: quizResult)
//        } else {
//            currentQuestionIndex += 1
//            questionFactory?.requestNextQuestion()
//        }
//    }
    
//    private func show(quiz result: QuizResultsViewModel) {
//        let bestGameRecord = statisticService.bestGame
//        let formattedDate = bestGameRecord.date.dateTimeString
//        let message = """
//            Ваш результат: \(result.text)\n
//            Лучший результат: \(bestGameRecord.correct)/\(bestGameRecord.total) (\(formattedDate))
//            Точность: \(String(format: "%.2f", statisticService.totalAccuracy * 100))%
//            """
//        let alertModel = AlertModel(
//            title: result.title,
//            message: message,
//            buttonText: result.buttonText
//        ) { [weak self] in
//            self?.restartQuiz()
//        }
//        alertPresenter.presentAlert(alertModel: alertModel)
//    }

    private func restartQuiz() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.reset()
        questionFactory?.requestNextQuestion()
    }
    
}

//MARK - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            finishGame()
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
