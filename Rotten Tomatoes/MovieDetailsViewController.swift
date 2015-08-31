//
//  MovieDetailsViewController.swift
//  Rotten Tomatoes
//
//  Created by Andrew Montgomery on 8/25/15.
//  Copyright (c) 2015 Andrew Montgomery. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    
    var movie: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String
        
        
        var urlStringThumb = movie.valueForKeyPath("posters.thumbnail") as! String
        var urlStringFull = ""
        
        // Hack to get the high rez poster art
        var range = urlStringThumb.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            urlStringFull = urlStringThumb.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }

        // Load the thumbnail first
        if let urlThumb = NSURL(string: urlStringThumb) {
            imageView.setImageWithURL(urlThumb)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
