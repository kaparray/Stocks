//
//  ViewController.swift
//  Stocks
//
//  Created by Kirill on 11/09/2018.
//  Copyright © 2018 Kaparray. All rights reserved.
//

import UIKit

import Foundation

extension UIImage {
    convenience init?(url: URL?) {
        guard let url = url else { return nil }
        
        do {
            let data = try Data(contentsOf: url)
            self.init(data: data)
        } catch {
            print("Cannot load image from url: \(url) with error: \(error)")
            return nil
        }
    }
}

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
   
    private let companies : [String: String] = ["Apple": "AAPL",
                                                "Microsoft": "MSFT",
                                                "Google": "GOOG",
                                                "Amazon": "AMZN",
                                                "Facebook": "FB"];
    
    
    
  
  
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var companyPickerView: UIPickerView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var priceChangeLabel: UILabel!
    @IBAction func updateInfoButton(_ sender: Any) {
        self.requestQuoteUpdate()
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.logoImageView.contentMode = .scaleAspectFit
        
    
        self.companyNameLabel.text = "kaparray"
        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self
        
        self.activityIndicator.hidesWhenStopped = true
        
        //self.requestAllCompany()
        
        self.requestQuoteUpdate()
    
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.companies.keys.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Array(self.companies.keys)[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        return self.requestQuoteUpdate()
    }
    
    
    
    // GO TO NETWORK FOR PICKERVIEW
//    private func requestAllCompany(){
//        let url = URL(string: "https://api.iextrading.com/1.0/stock/market/list/infocus")!
//
//        let dataTask = URLSession.shared.dataTask(with: url){data, response, error in
//            guard
//                error == nil,
//                (response as? HTTPURLResponse)?.statusCode == 200,
//                let data = data
//                else{
//                    print("Network error")
//                    return
//            }
//
//            self.parseAllCompany(data: data)
//        }
//
//        dataTask.resume()
//    }

    
    
    // PARSE COMPANY INFORMATION
    private func parseAllCompany(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String
                else {
                    print("")
                    return
            }
            DispatchQueue.main.async {
                self.fillingCompanies(companyName: companyName, symbol: companySymbol)
            }
        } catch {
            print("JSSON parsing error: " + error.localizedDescription)
        }
    }
    
    private func fillingCompanies(companyName: String, symbol: String){
        
    }
    
    
    
    
    // GO TO NETWORK FOR COMPANY INFORMATION
    private func requestQuote(for symbol: String){
        let url = URL(string: "https://api.iextrading.com/1.0/stock/\(symbol)/quote")!
        
        let dataTask = URLSession.shared.dataTask(with: url){data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else{
                print("Network error")
                return
            }
            
            self.parseQuote(data: data)
        }
        
        dataTask.resume()
    }
    
    
    // PARSE COMPANY INFORMATION
    private func parseQuote(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            guard
                let json = jsonObject as? [String: Any],
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double
            else {
                print("")
                return
            }
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName, symbol: companySymbol, price: price, priceChange: priceChange)
            }
        } catch {
            print("JSSON parsing error: " + error.localizedDescription)
        }
    }
        

    
    // SHOW INFO IN DISPLAY ABOUT COMPANY
    private func displayStockInfo(companyName: String, symbol: String, price: Double, priceChange: Double){
        self.activityIndicator.stopAnimating()
        self.companyNameLabel.text = "\(companyName)"
        self.companySymbolLabel.text = "\(symbol)"
        self.priceLabel.text = "\(price) $"
        self.priceChangeLabel.text = "\(priceChange) $"
        
        if(priceChange < 0){
            self.priceChangeLabel.textColor = UIColor.red
        }else if(priceChange > 0){
            self.priceChangeLabel.textColor = UIColor.green
        }else{
            self.priceChangeLabel.textColor = UIColor.black
        }
    }
    
    // DATA ZEROING
    private func requestQuoteUpdate(){
        self.activityIndicator.startAnimating()
        self.companyNameLabel.text = "-"
        self.companySymbolLabel.text = "-"
        self.priceLabel.text = "-"
        self.priceChangeLabel.text = "-"
        self.priceChangeLabel.textColor = UIColor.black
        
        
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        self.requestQuote(for: selectedSymbol)
        
        self.logoImageView.image = UIImage(url: URL(string: "https://storage.googleapis.com/iex/api/logos/\(selectedSymbol).png"))
        
      
    }

}



