//
//  GeneralViewController.swift
//  CurrencyConverter
//
//  Created by Pavel Boltromyuk on 2.11.23.
//

import UIKit

class GeneralViewController: UIViewController {
    
    @IBOutlet private weak var secondCurrencyLabel: UILabel!
    @IBOutlet private weak var firstCurrencyTextField: UITextField!
    @IBOutlet private weak var secondCurrencyTextField: UITextField!
    @IBOutlet private weak var gradientBackgroundView: UIView!
    @IBOutlet private weak var currencyPickerView: UIPickerView!
    @IBOutlet private weak var customToolbarView: UIView!
    
    // MARK: - Private properties
    
    private lazy var gradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.type = .axial
        gradient.colors = [
            UIColor.white.cgColor,
            UIColor.sailColor?.cgColor ?? UIColor.blue.cgColor,
            UIColor.melroseColor?.cgColor ?? UIColor.blue.cgColor
        ]
        gradient.locations = [0, 0.25, 1]
        return gradient
    }()
    
    private let networkService = NetworkService()
    private var symbols = [Symbol]()
    private var rates = [Rate]()
    private var selectedCurrency = "EUR"
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        gradient.frame = gradientBackgroundView.frame
        gradientBackgroundView.layer.addSublayer(gradient)
        
        currencyPickerView.delegate = self
        currencyPickerView.dataSource = self
        
        firstCurrencyTextField.addTarget(self, action: #selector(firstCurrencyTextFieldDidChange(_:)), for: .editingChanged)
        
        setupLabelActions()
        getRate()
        getСurrencies()
    }
    
    // MARK: - SetupUI
    
    private func setupLabelActions() {
        secondCurrencyLabel.isUserInteractionEnabled = true
        secondCurrencyLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedSecondCurrency)))
    }
    
    private func priceCalculation() {
        let firstCurrency = Float(firstCurrencyTextField.text ?? "1") ?? 1
        let ratio = rates.first { $0.abbreviation == selectedCurrency }?.ratio ?? 1
        let result = firstCurrency * ratio
        secondCurrencyTextField.text = String(format: "%.2f", result)
    }
    
    // MARK: - Actions
    
    @objc func tappedSecondCurrency(sender: UITapGestureRecognizer) {
        currencyPickerView.isHidden = false
        customToolbarView.isHidden = false
    }
    
    @objc func firstCurrencyTextFieldDidChange(_ textField: UITextField) {
        priceCalculation()
    }

    @IBAction func tappedDoneToolBarButton(_ sender: Any) {
        currencyPickerView.isHidden = true
        customToolbarView.isHidden = true
        secondCurrencyLabel.text = selectedCurrency.isEmpty ? "USD" : selectedCurrency
        priceCalculation()
    }
    
    @IBAction func tappedCancelToolBarButton(_ sender: Any) {
        currencyPickerView.isHidden = true
        customToolbarView.isHidden = true
    }
    
    // MARK: - Network
    
    private func getСurrencies() {
        guard let symbolsUrl = Constants.symbolsUrl else { return }
        let params = ["access_key": Constants.accessKey]
        networkService.makeRequest(for: symbolsUrl, method: .get, query: .path, params: params) { [weak self] data, error in
            if let error {
                self?.presentAlert(title: "Error", message: error.localizedDescription, cancelTitle: "Ok")
                return
            }
            guard let data else {
                self?.presentAlert(title: "Error", message: "An unexpected error has occurred. Try again.", cancelTitle: "Ok")
                return
            }
            let symbols = try? JSONDecoder().decode(Symbols.self, from: data)
            self?.symbols = symbols?.symbols.compactMap({ key, value in
                return Symbol(name: value, abbreviation: key)
            }) ?? []
            DispatchQueue.main.async {
                self?.currencyPickerView.reloadAllComponents()
            }
        }
    }
    
    private func getRate() {
        guard let rateUrl = Constants.rateUrl else { return }
        var secondCurrency = secondCurrencyLabel.text ?? "USD"
        
        if secondCurrency.isEmpty {
            secondCurrency = "USD"
        }
        
        let params = [
            "access_key": Constants.accessKey
        ]
        networkService.makeRequest(for: rateUrl, method: .get, query: .path, params: params) { [weak self] data, error in
            if let error {
                self?.presentAlert(title: "Error", message: error.localizedDescription, cancelTitle: "Ok")
                return
            }
            guard let data else {
                self?.presentAlert(title: "Error", message: "An unexpected error has occurred. Try again.", cancelTitle: "Ok")
                return
            }
            let rates = try? JSONDecoder().decode(LatestRates.self, from: data)
            self?.rates = rates?.rates.compactMap({ key, value in
                return Rate(abbreviation: key, ratio: value)
            }) ?? []
        }
    }
    
    
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension GeneralViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return symbols.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let symbol = symbols[row]
        selectedCurrency = symbol.abbreviation
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let symbol = symbols[row]
        return "\(symbol.abbreviation) - \(symbol.name)"
    }
}
