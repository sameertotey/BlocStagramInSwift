//
//  MediaTableViewCell.swift
//  BlocStagramInSwift
//
//  Created by Sameer Totey on 1/20/15.
//  Copyright (c) 2015 Sameer Totey. All rights reserved.
//

import UIKit

class MediaTableViewCell: UITableViewCell {
    
    var mediaItem: Media = Media() {
        didSet {
            mediaImageView.image = mediaItem.image;
            usernameAndCaptionLabel.attributedText = usernameAndCaptionString()
            commentLabel.attributedText = commentString()
            println("commentLabel: \(commentLabel.text!)")
        }
    }
    
    @IBOutlet weak var mediaImageView: UIImageView!
    
    @IBOutlet weak var usernameAndCaptionLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    struct Styling {
        static let lightFont = UIFont(name:"HelveticaNeue-Thin", size: 11)
        static let boldFont = UIFont(name: "HelveticaNeue-Bold", size: 11)
        static let usernameLabelGray = UIColor(red: 0.933, green: 0.933, blue: 9.933, alpha: 1) /*#eeeeee*/
        static let commentLabelGray = UIColor(red: 0.898, green: 0.898, blue: 0.898, alpha: 1) /*#e5e5e5*/
        static let linkColor = UIColor(red: 0.345, green: 0.314, blue: 0.427, alpha: 1) /*#58506d*/
        
        // Define paragraph styling, we make modificatons in the load method of the class
        static let mutableParagraphStyle = NSMutableParagraphStyle()
        static var paragraphStyle = NSParagraphStyle()
    }
    
    override class func load() {
        Styling.mutableParagraphStyle.headIndent = 20.0
        Styling.mutableParagraphStyle.firstLineHeadIndent = 20.0
        Styling.mutableParagraphStyle.tailIndent = -20.0
        Styling.mutableParagraphStyle.paragraphSpacingBefore = 5.0
        Styling.paragraphStyle = Styling.mutableParagraphStyle
    }
    
    
    class func heightForMediaItem(mediaItem: Media, width :CGFloat) -> CGFloat {
        // Make a cell
//        let layoutCell = MediaTableViewCell(style: .Default, reuseIdentifier: cellReuseIdentifier)
        let layoutCell = NSBundle.mainBundle().loadNibNamed("MediaTableViewCell", owner: self, options: nil)[0] as MediaTableViewCell

        
        // Set it to the given width, and the maximum possible height
        layoutCell.frame = CGRectMake(0, 0, width, CGFloat.max)
        
        // Give it the media item
        layoutCell.mediaItem = mediaItem
        
        // Make it adjust the image view and labels
        layoutCell.layoutSubviews()
        
        // The height will be wherever the bottom of the comments label is 
        return CGRectGetMaxY(layoutCell.commentLabel.frame)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func usernameAndCaptionString() -> NSAttributedString {
        let usernameFontSize = CGFloat(15)
        let baseString = "\(self.mediaItem.user!.userName!) \(self.mediaItem.caption!)"
        
        // Make an attributed string, with the "username" bold

        var mutableUsernameAndCaptionString: NSMutableAttributedString = NSMutableAttributedString(string: baseString, attributes: [NSFontAttributeName: Styling.lightFont!.fontWithSize(usernameFontSize), NSParagraphStyleAttributeName: Styling.paragraphStyle])
        
        let usernameRange = (baseString as NSString).rangeOfString(self.mediaItem.user!.userName!)
        
        mutableUsernameAndCaptionString.addAttribute(NSFontAttributeName, value: Styling.boldFont!.fontWithSize (usernameFontSize), range: usernameRange)
        mutableUsernameAndCaptionString.addAttribute(NSForegroundColorAttributeName, value: Styling.linkColor, range: usernameRange)
        
        return mutableUsernameAndCaptionString
    }
    
    func commentString() -> NSAttributedString {
        
        let commentString = NSMutableAttributedString()
        
        for comment in mediaItem.comments {
            // Make a string that says "username comment text" followed by a line break
            let baseString = "\(comment.from!.userName!) \(comment.text!)\n"
        
            // Make an attributed string, with the "username" bold
            var oneCommentString: NSMutableAttributedString = NSMutableAttributedString(string: baseString, attributes: [NSFontAttributeName: Styling.lightFont!, NSParagraphStyleAttributeName: Styling.paragraphStyle])
            
            let usernameRange = (baseString as NSString).rangeOfString(comment.from!.userName!)
        
            oneCommentString.addAttribute(NSFontAttributeName, value: Styling.boldFont!, range: usernameRange)
            oneCommentString.addAttribute(NSForegroundColorAttributeName, value: Styling.linkColor, range: usernameRange)
            commentString.appendAttributedString(oneCommentString)
        }
        return commentString
    }
    
//    - (CGSize) sizeOfString:(NSAttributedString *)string {
//    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.contentView.bounds) - 40, 0.0);
//    CGRect sizeRect = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
//    sizeRect.size.height += 20;
//    sizeRect = CGRectIntegral(sizeRect);
//    return sizeRect.size;
//    }
    
    func sizeOfString(string: NSAttributedString) -> CGSize {
        let maxSize = CGSizeMake(CGRectGetWidth(self.contentView.bounds) - 40, 0.0)
        var sizeRect = string.boundingRectWithSize(maxSize, options: .UsesLineFragmentOrigin, context: nil)
        sizeRect.size.height = sizeRect.size.height + CGFloat(20)
        sizeRect = CGRectIntegral(sizeRect)
        
        return sizeRect.size
    }
    
//    - (void) layoutSubviews {
//    [super layoutSubviews];
//    
//    CGFloat imageHeight = self.mediaItem.image.size.height / self.mediaItem.image.size.width * CGRectGetWidth(self.contentView.bounds);
//    self.mediaImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), imageHeight);
//    
//    CGSize sizeOfUsernameAndCaptionLabel = [self sizeOfString:self.usernameAndCaptionLabel.attributedText];
//    self.usernameAndCaptionLabel.frame = CGRectMake(0, CGRectGetMaxY(self.mediaImageView.frame), CGRectGetWidth(self.contentView.bounds), sizeOfUsernameAndCaptionLabel.height);
//    
//    CGSize sizeOfCommentLabel = [self sizeOfString:self.commentLabel.attributedText];
//    self.commentLabel.frame = CGRectMake(0, CGRectGetMaxY(self.usernameAndCaptionLabel.frame), CGRectGetWidth(self.bounds), sizeOfCommentLabel.height);
//    
//    // Hide the line between cells
//    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
//    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let imageHeight = mediaItem.image!.size.height / mediaItem.image!.size.width * CGRectGetWidth(self.contentView.bounds)
        self.mediaImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), imageHeight)
        
        let sizeOfUsernameAndCaptionLabel = sizeOfString(self.usernameAndCaptionLabel.attributedText)
        self.usernameAndCaptionLabel.frame = CGRectMake(0, CGRectGetMaxY(self.mediaImageView.frame), CGRectGetWidth(self.bounds), sizeOfUsernameAndCaptionLabel.height)
        
        let sizeOfCommentLabel = sizeOfString(self.commentLabel.attributedText)
        self.commentLabel.frame = CGRectMake(0, CGRectGetMaxY(self.usernameAndCaptionLabel.frame), CGRectGetWidth(self.bounds), sizeOfCommentLabel.height)
        
        // Hide the line between cells
        self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
        
    }
    
    
    
}
