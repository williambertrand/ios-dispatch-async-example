//
//  ViewController.swift
//  vurb-take-home-mobile-exerceise
//
//  Created by William Bertrand on 1/24/16.
//  Copyright © 2016 William. All rights reserved.
//

import UIKit

var urlString = "https://gist.githubusercontent.com/helloandrewpark/0a407d7c681b833d6b49/raw/5f3936dd524d32ed03953f616e19740bba920bcd/gistfile1.js"

class ViewController: UIViewController {
    
    //This will create the cards and the table view
    var cardCreator : CardCreator!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let windowFrame = self.view.frame
        let windowSize = self.view.frame.size
        
        //title label
        let titleLabel : UILabel = UILabel(frame: CGRect(x: windowSize.width * 0.05, y: windowSize.height * 0.05, width: windowSize.width * 0.9, height: windowSize.height * 0.2))
        titleLabel.text = "Vurb Mobile Exercise Demo : Will Bertrand"
        titleLabel.textAlignment = NSTextAlignment.Center
        self.view.addSubview(titleLabel)
        
        //frame for the card table view
        let cardRect = CGRect(x: windowFrame.width*0.1, y: windowFrame.height*0.2, width: windowFrame.width*0.8, height: windowFrame.height*0.8)
        
        //create the cardtableview from the url and add its tableview to the view
        cardCreator = CardCreator(urlForCards: urlString, rectForTable: cardRect)
        self.view.addSubview(cardCreator.cardsTableView)
    
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    


}

