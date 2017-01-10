//
//  HudView.swift
//  TrackLocation
//
//  Created by iUS on 11/9/16.
//  Copyright © 2016 ayush. All rights reserved.//
//

import Foundation
import UIKit

//Head-up Display
class HudView: UIView{
    
    var text = ""
    
    //convenience constructor
    class func hudView(inView view: UIView , animated : Bool) -> HudView {
        
        //add the new HudView object as a subview on top of the “parent” view object. This is the navigation controller’s view so the HUD will cover the entire screen.
        let hudView = HudView(frame: view.bounds)
        print("View bounds : \(view.bounds)")
        print("View frame : \(view.frame)")
        hudView.isOpaque = false
        view.addSubview(hudView)
        
        //It also sets view’s isUserInteractionEnabled property to false. While the HUD is showing you don’t want the user to interact with the screen anymore. The user has already pressed the Done button and the screen is in the process of closing.
        view.isUserInteractionEnabled = false
        
        hudView.show(animated: animated)
        return hudView
    }
    
    
    //The draw() method is invoked whenever UIKit wants your view to redraw itself. Recall that everything in iOS is event-driven. The view doesn’t draw anything on the screen unless UIKit sends it the draw() event. That means you should never call draw() yourself.
    override func draw(_ rect: CGRect) {
        
        //When working with UIKit or Core Graphics (CG, get it?) you use CGFloat instead of the regular Float or Double.
        let boxWidth : CGFloat = 96
        let boxHeight : CGFloat = 96
        
        //The HUD rectangle should be centered horizontally and vertically on the screen. The size of the screen is given by bounds.size (this really is the size of HudView itself, which spans the entire screen).
        let boxRect = CGRect(x: (bounds.size.width - boxWidth) / 2,
                             y: (bounds.size.height - boxHeight) / 2,
                             width: boxWidth,
                             height: boxHeight)
        
        //UIBezierPath is a very handy object for drawing rectangles with rounded corners. You just tell it how large the rectangle is and how round the corners should be. Then you fill it with an 80% opaque dark gray color.
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        
        /*
           Failable initializers
            To create the UIImage you used if let to unwrap the resulting object. That’s because UIImage(named) is a so-called "failable initializer".
            It is possible that loading the image fails, because there is no image with the specified name or the file doesn’t really contain a valid image.
            That’s why UIImage’s init(named) method is really defined as init?(named). The question mark indicates that this method returns an optional. If there was a problem loading the image, it returns nil instead of a brand spanking new UIImage object.
         */
        
        //This loads the checkmark image into a UIImage object. Then it calculates the position for that image based on the center coordinate of the HUD view (center) and the dimensions of the image (image.size).
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.draw(at: imagePoint)
        }
        
        
        
        //When drawing text you first need to know how big the text is, so you can figure out where to position it.
        //First, you create the UIFont object that you’ll use for the text. This is a “System” font of size 16. As of iOS 9, the system font is San Francisco (on iOS 8 and before it was Helvetica Neue.
        //So in the dictionary from draw(), the NSFontAttributeName key is associated with the UIFont object, and the NSForegroundColorAttributeName key is associated with the UIColor object. In other words, the attribs dictionary describes what the text will look like.
        //You use these attributes and the string from the text property to calculate how wide and tall the text will be. The result ends up in the textSize constant, which is of type CGSize. (As you can tell, CGPoint, CGSize, and CGRect are types you use a lot when making your own views.)
        //Finally, you calculate where to draw the text (textPoint), and then draw it.
        let attribs = [ NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                        NSForegroundColorAttributeName: UIColor.white ]
        let textSize = text.size(attributes: attribs)
        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4)
        text.draw(at: textPoint, withAttributes: attribs)
        
    }
    
    func show(animated : Bool){
        if animated{
            
            // 1 - Setup the initial state of the view before the animation starts.Here you set alpha to 0, making the view fully transparent. You also set the transform to a scale factor of "1.3" . We’re not going to go into depth on transforms here, but basically this means the view is initially stretched out.
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            // 2 - Call UIView.animate(withDuration:...) to setup ananimation.You give this a closure that describes the animation.UIKit will animate the properties that you change inside the closure from their initial state to the final state.
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            
                // 3 - Inside the closure,setup the new state of the view that it should have after the animation completes. You set alpha to 1, which means the HudView is now fully opaque. You also set the transform to the “identity” transform, restoring the scale back to normal. Because this code is part of a closure, you need to use self to refer to the HudView instance and its properties. That’s the rule for closures.
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            },
            completion: nil)
            
              
            
        }
    }
}



