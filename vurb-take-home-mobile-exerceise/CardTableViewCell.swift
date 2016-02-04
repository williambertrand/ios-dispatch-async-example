//
//  CardTableViewCell.swift
//  vurb-take-home-mobile-exerceise
//
//  Created by William Bertrand on 1/24/16.
//  Copyright © 2016 William. All rights reserved.
//

import Foundation
import UIKit


/*
 * Custom UITableViewCell for the cards to be displayed
 */
class CardTableViewCell : UITableViewCell {
    
    var type: CardType! //CardType defined in CardCreator.swift
    var title: String!
    var thumbnailImage : UIImage!
    var movieExtraImage : UIImage!
    var musicLink: String!
    
    //ui components of the card table view cell
    var backgroundColorView: UIView!
    var titleLabel : UILabel!
    var thumbnailImageView : UIImageView!
    var movieExtraImageView : UIImageView!
    var musicLinkButton : UIButton!
    
    let padding : CGFloat = 5
    
    /*
     * initialize subvies and add them to content views
     */
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clearColor()
        selectionStyle = .None
        
        backgroundColorView = UIView(frame:CGRectZero)
        contentView.addSubview(backgroundColorView)
        
        titleLabel = UILabel(frame: CGRectZero)
        titleLabel.textAlignment = .Left
        titleLabel.textColor=UIColor.blackColor()
        contentView.addSubview(titleLabel)
        
        thumbnailImageView = UIImageView(frame: CGRectZero)
        contentView.addSubview(thumbnailImageView)
        
        movieExtraImageView = UIImageView(frame: CGRectZero)
        contentView.addSubview(movieExtraImageView)
        
        musicLinkButton = UIButton(frame:CGRectZero)
        musicLinkButton.addTarget(self, action: "openMusicLink", forControlEvents: .TouchUpInside)
        contentView.addSubview(musicLinkButton)
        
        setNeedsLayout()
    
    }
    
    /*
     * Layout subview rects: differentiate card types to decide if extraImage and musiclinkbutton are present
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        //create frames for all subvies of the card table cell
        backgroundColorView.frame = CGRect(x: 0, y: 0, width: frame.width, height: contentView.frame.height*0.8)
        
        titleLabel.frame = CGRect(x:padding, y:padding, width:frame.width, height: frame.height / 4)
        
        thumbnailImageView.frame = CGRect(x: padding, y: padding + titleLabel.frame.height, width: frame.height / 2, height: frame.height / 2)
        
        if type != nil {
            if type == CardType.Movie {
                movieExtraImageView.frame = CGRect(x: frame.width/2, y: padding + titleLabel.frame.height, width: frame.width/2.5, height: frame.height/2.5)
            }
            else {
                movieExtraImageView.frame = CGRectZero
            }
            
            if type == CardType.Music {
                musicLinkButton.frame = CGRect(x: self.frame.width*0.5, y: self.frame.height*0.5, width: self.frame.width*0.4, height: self.frame.height*0.2)
            }
            else {
                musicLinkButton.frame = CGRectZero
            }
            
        }
        
    }
    
    //make movieimage nil in case card is reused as  non-moive type
    
    override func prepareForReuse() {
        //remove images from card so it ready to be reused, but leave imageviews on
        thumbnailImageView.image = nil
        movieExtraImageView.image = nil
        super.prepareForReuse()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //action for the music link button
    func openMusicLink() {
        UIApplication.sharedApplication().openURL(NSURL(string:self.musicLink)!)
    }
    
    
}
