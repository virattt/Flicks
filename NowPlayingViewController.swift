//
//  NowPlayingViewController.swift
//  Flicks
//
//  Created by virat_singh on 3/21/17.
//  Copyright © 2017 viratsingh. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class NowPlayingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var networkError: UILabel!
    @IBOutlet weak var moviesTableView: UITableView!
    
    var movies: [NSDictionary]?
    var BASE_URL: NSURL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkError.isHidden = true
        networkError.backgroundColor = UIColor.black
        networkError.alpha = CGFloat(Float(0.8))
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        moviesTableView.insertSubview(refreshControl, at: 0)


        // Do any additional setup after loading the view.
        
        moviesTableView.delegate = self
        moviesTableView.dataSource = self
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NowPlayingMovieCell", for: indexPath) as! MovieCell
        
        let movie = movies![indexPath.row]
        let title = movie["title"] as! String
        let description = movie["overview"] as! String
        cell.movieTitle.text = title
        cell.movieDescription.text = description
        
        let baseUrl = "https://image.tmdb.org/t/p/w500"
        if let posterPath = movie["poster_path"] as? String {
            let imageUrl = NSURL(string: baseUrl + posterPath)
            cell.movieImage.setImageWith(imageUrl! as URL)
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        moviesTableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = moviesTableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! MovieDetailViewController
        detailViewController.movie = movie
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }
    
    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        
        // ... Create the URLRequest `myRequest` ...
        let url = BASE_URL
        let request = NSURLRequest(
            url: url! as URL,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest,
                                                        completionHandler: { (dataOrNil, response, error) in
                                                            if let data = dataOrNil {
                                                                if let responseDictionary = try! JSONSerialization.jsonObject(
                                                                    with: data, options:[]) as? NSDictionary {
                                                                    print("response: \(responseDictionary)")
                                                                    
                                                                    self.movies = responseDictionary["results"] as! [NSDictionary]
                                                                    self.moviesTableView.reloadData()
                                                                    refreshControl.endRefreshing()
                                                                }
                                                            } else {
                                                                self.networkError.isHidden = false
                                                            }
        })
        task.resume()

    }
    
    func loadData() {
        let url = BASE_URL
        let request = NSURLRequest(
            url: url! as URL,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        
        // Show loading state
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // Execute task
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest,
                                                        completionHandler: { (dataOrNil, response, error) in
                                                            if let data = dataOrNil {
                                                                if let responseDictionary = try! JSONSerialization.jsonObject(
                                                                    with: data, options:[]) as? NSDictionary {
                                                                    // Hide the loading state
                                                                    MBProgressHUD.hide(for: self.view, animated: true)
                                                                    
                                                                    self.movies = responseDictionary["results"] as! [NSDictionary]
                                                                    self.moviesTableView.reloadData()
                                                                }
                                                            } else {
                                                                self.networkError.isHidden = false
                                                            }
        })
        task.resume()

    }
 
}
