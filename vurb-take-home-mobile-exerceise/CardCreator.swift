//
//  CardCreator.swift
//  vurb-take-home-mobile-exerceise
//
//  Created by William Bertrand on 1/24/16.
//  Copyright © 2016 William. All rights reserved.
//

import Foundation
import UIKit

//CArd type: more types can be added here
enum CardType {
    case Place, Movie, Music, Blank
}


// Card class: Each cell in the CArdTableView is associated with a card object
class Card {
    var type: CardType
    var title: String?
    var thumbnail : UIImage?
    var cardSpecificValues : [String:AnyObject]
    var backgroundColor : UIColor
    
    init(typeString:String, titleString : String, thumbnailImage:UIImage, extras:[String:AnyObject]){
        title = titleString
        thumbnail = thumbnailImage
        cardSpecificValues = extras
        type = .Blank
        backgroundColor = UIColor.clearColor()
        
        if typeString == "place" {
            type = .Place
        }
        else if typeString == "movie"{
            type = .Movie
        }
        
        else if typeString == "music" {
            type = .Music
        }
        
    }
    
    
}


//creates the cards and the tableview to add all the cards to
class CardCreator : NSObject,UITableViewDelegate,UITableViewDataSource {
    
    var cards:[Card]!
    var cardsTableView : UITableView!
    
    //init with a url and a frame rect
    init(urlForCards:String, rectForTable:CGRect){
        super.init()
        cards = [Card]()
        createCardsFromUrl(urlForCards)
        cardsTableView = UITableView(frame: rectForTable)
        cardsTableView.showsVerticalScrollIndicator = false
        cardsTableView.delegate = self
        cardsTableView.dataSource = self
        
        //register cell class
        cardsTableView.registerClass(CardTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(CardTableViewCell))
    }
    
    
    required init(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //tableview delegate methods----------------------------
    
    
    //tableview should have as many cells as cards in "cards"
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cards.count
    }
    
    //create a cell from a card in "cards"
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cardForCell = cards[indexPath.row]
        let cell = cardsTableView.dequeueReusableCellWithIdentifier(NSStringFromClass(CardTableViewCell), forIndexPath: indexPath) as! CardTableViewCell
        cell.type = cardForCell.type
        cell.title = cardForCell.title
        cell.titleLabel.text = cardForCell.title
        cell.titleLabel.textColor = UIColor.whiteColor()
        cell.thumbnailImageView.image = cardForCell.thumbnail
        cell.backgroundColorView.backgroundColor = cardForCell.backgroundColor
        
        switch cardForCell.type {
        case .Place:break
        case .Movie:
            cell.movieExtraImageView.image = (cardForCell.cardSpecificValues["movieExtraImage"] as! UIImage)
            cell.movieExtraImageView.contentMode = .ScaleAspectFit
        case .Music:
            cell.musicLink = (cardForCell.cardSpecificValues["musicUrlString"] as! String)
            cell.musicLinkButton.setTitle("Click to Listen", forState: .Normal)
            cell.musicLinkButton.backgroundColor = UIColor.lightGrayColor()
            cell.musicLinkButton.titleLabel?.textAlignment = .Center
        default: break
            
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return cardsTableView.frame.height / 3
    }
    
    /*
     * Bulk of the work to be done in this method.
     * Retreive the JSON from the url, then parse and create cards
     * Once cards are created, perform image processing in parallel using dispatch_groups
     */
    
    func createCardsFromUrl (urlString:String){
        
        var cardsArrayToProcess : [Card] = [Card]()
        let url : NSURL = NSURL(string: urlString)!
        let data = NSData(contentsOfURL: url)!
        
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            
            if let cardsJson = json["cards"] as? [[String: AnyObject]] {
                for c in cardsJson {
                    if let title = c["title"] as? String{
                        if let type = c["type"] as? String {
                            if let imageUrlString = c["imageURL"] as? String {
                                let imageUrl = NSURL(string: imageUrlString)
                                let imageData = NSData(contentsOfURL: imageUrl!)
                                let image = UIImage(data:imageData!)
                                
                                var extras : [String:AnyObject] = [String:AnyObject]()
                                
                                if type == "movie"{
                                    
                                    if let movieUrlString : String = c["movieExtraImageURL"] as? String {
                                        let movieExtraImageUrl = NSURL(string: movieUrlString)
                                        let movieExtraImageData : NSData = NSData(contentsOfURL: movieExtraImageUrl!)!
                                        extras["movieExtraImage"] = UIImage(data:movieExtraImageData)
                                        
                                    }
                                    
                                }
                                
                                else if type == "music" {
                                    if let musicUrlString:String = c["musicVideoURL"] as? String {
                                        extras["musicUrlString"] = musicUrlString
                                    }
                                }
                                
                                let card = Card(typeString: type, titleString: title, thumbnailImage: image!, extras: extras)
                                //do imageprocessing and such here before adding card to array 
                                //add card to array once done
                               
                                cardsArrayToProcess.append(card)
                            }
                        }
                        
                    }
                    
                }
            }
            
            //do image processing for each card in parallel
            for index in 0..<cardsArrayToProcess.count {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0)) { () -> Void in
                    let card = cardsArrayToProcess[index] as Card
                    let cardImage : UIImage = card.thumbnail!
                    let imageProcessGroup = dispatch_group_create()

                    var avgColor : UIColor = UIColor()
                    var croppedThumbnail : UIImage = UIImage()
                    
                    dispatch_group_enter(imageProcessGroup)
                    dispatch_group_async(imageProcessGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                        croppedThumbnail = self.cropImage(cardImage)
                        dispatch_group_leave(imageProcessGroup)
                    })
                    
                    
                    dispatch_group_enter(imageProcessGroup)
                    dispatch_group_async(imageProcessGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                        avgColor = (cardImage.averageColor())
                        dispatch_group_leave(imageProcessGroup)
                    })
                    
                    //once both tasks are done, add the image-processed cards to the cards array -> this will then
                    //cause the cardsTableView to update
                    dispatch_group_notify(imageProcessGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                        card.thumbnail = croppedThumbnail
                        card.backgroundColor = avgColor
                        self.cards.append(card)
                        dispatch_async(dispatch_get_main_queue()){
                            return
                        }
                        
                    })
                    
                    
                }
                
                
            }

            
        }
        catch {
            print("error serializing json: \(error)")
        }
        
        
    }
    
    //helper method to crop the image
    func cropImage(imageToCrop : UIImage) -> UIImage{
        let contextImage = UIImage(CGImage: imageToCrop.CGImage!)
        
        let contextSize = contextImage.size
        
        var x: CGFloat = 0.0
        var y : CGFloat = 0.0
        var cgWidth : CGFloat = 0.0
        var cgHeight : CGFloat = 0.0
        
        if contextSize.width > contextSize.height {
            x = ((contextSize.width - contextSize.height) / 2)
            y = 0
            cgWidth = contextSize.height
            cgHeight = contextSize.height
        }
            
        else {
            x = 0
            y = ((contextSize.height - contextSize.width) / 2)
            cgWidth = contextSize.width
            cgHeight = contextSize.width
        }
        
        let cropRect : CGRect = CGRectMake(x,y, cgWidth, cgHeight)
        
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(contextImage.CGImage, cropRect)!
        
        let image: UIImage = UIImage(CGImage: imageRef, scale: imageToCrop.scale, orientation: imageToCrop.imageOrientation)
        
        return image
    }
    

    
}

