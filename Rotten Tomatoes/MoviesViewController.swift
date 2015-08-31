//
//  MoviesViewController.swift
//  Rotten Tomatoes
//
//  Created by Andrew Montgomery on 8/25/15.
//  Copyright (c) 2015 Andrew Montgomery. All rights reserved.
//

import UIKit
import KVNProgress

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkErrorLabel: UILabel!
    
    var movies: [NSDictionary]?
    var refreshControl: UIRefreshControl!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the UIRefreshControl
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        fetchURL()
        
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fetchURL() {
        let url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/box_office.json?apikey=dagqdghwaq3e3mxyrp7kmmj5&limit=20&country=us")!
        let request = NSURLRequest(URL: url)
        self.startSpinner()
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            if data != nil {
                let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
                if let json = json {
                    self.movies = json["movies"] as? [NSDictionary]
                    self.tableView.reloadData()
                    self.stopSpinner()
                    println("response: \(self.movies)")
                }
            } else {
                //self.tableView.reloadData()
                self.stopSpinner()
                self.refreshControl.endRefreshing()
                self.showNetworkError()
            }
        }
    }
    
    private func startSpinner() {
        if refreshControl.refreshing != true {
            KVNProgress.show()
        }
    }
    
    private func stopSpinner() {
        KVNProgress.dismissWithCompletion { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    private func showNetworkError() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            let currentCenter = self.networkErrorLabel.center
            let currentX = currentCenter.x
            let currentY = currentCenter.y
            println("currentY: \(currentY)")
            self.networkErrorLabel.center = CGPointMake(currentX, 74.5)
        })
    }
    
    private func hideNetworkError() {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            let currentCenter = self.networkErrorLabel.center
            let currentX = currentCenter.x
            self.networkErrorLabel.center = CGPointMake(currentX, 53.5)
        })
    }
    
    // Delay used to simulate delays during prototyping
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        hideNetworkError()
        fetchURL()
        
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    // MARK: - TableViewDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
        
        if let abridgedCast = movie.valueForKeyPath("abridged_cast") as? NSArray {
            //var actors = Array<String>()
            var actors: [String] = []
            
            for index in 0...1 {
                if let castMember = abridgedCast[index] as? NSDictionary {
                    if let castMemberName = castMember["name"] as? String {
                        actors.append(castMemberName)
                    }
                }
            }
            cell.actorsLabel.text = ", ".join(actors)
        } else {
            cell.actorsLabel.text = ""
        }
        
        let url = NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!
        cell.posterView.setImageWithURL(url)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        
        let movie = movies![indexPath.row]
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        
        movieDetailsViewController.movie = movie
    }
    

}
