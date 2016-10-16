//
//  MoviesViewController.swift
//  MyMovies
//
//  Created by Duy Huynh Thanh on 10/12/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import AFNetworking
import MOHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var networkErrorView: UIView!
    
    let showTypeSegmentedControl = UISegmentedControl(items: ["List", "Grid"])
    var searchController:UISearchController!
    
    var movies = [NSDictionary]()
    var moviesFiltered = [NSDictionary]()
    var baseUrlLow = "https://image.tmdb.org/t/p/w45"
    var baseUrlHigh = "https://image.tmdb.org/t/p/original"
    var endpoint = "now_playing"
    var searchActive = false
    var inRefreshing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.frame.size.height = UIScreen.main.bounds.height - tableView.frame.origin.y - 49
        self.view.bringSubview(toFront: tableView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.frame.origin.y = tableView.frame.origin.y
        collectionView.frame.size.height = tableView.frame.size.height
        
        if let navigationBar = self.navigationController?.navigationBar {
            navigationBar.tintColor = UIColor.black
        }
        
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        let refreshControl2 = UIRefreshControl()
        refreshControl2.addTarget(self, action: #selector(self.refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        collectionView.insertSubview(refreshControl2, at: 0)
        
        
        showTypeSegmentedControl.selectedSegmentIndex = 0
        collectionView.isHidden = true
        showTypeSegmentedControl.addTarget(self, action: #selector(changeShowType), for: .valueChanged)
        showTypeSegmentedControl.sizeToFit()
        let segmentedButton = UIBarButtonItem(customView: showTypeSegmentedControl)
        searchBar.delegate = self
        let searchBarButton = UIBarButtonItem(customView: searchBar)
        navigationItem.rightBarButtonItems = [segmentedButton]
        navigationItem.leftBarButtonItems = [searchBarButton]
        
        
        networkErrorView.alpha = 0;
        networkErrorView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
        
        
        loadMovies()
    }
    
    func showNetworkError() {
        UIView.animate(withDuration: 0.5, animations: {
            self.networkErrorView.alpha = 1
            self.tableView.frame.origin.y = 106
            self.collectionView.frame.origin.y = 106
        })
    }
    func hideNetworkError() {
        UIView.animate(withDuration: 0.5, animations: {
            self.networkErrorView.alpha = 0
            self.tableView.frame.origin.y = 66
            self.collectionView.frame.origin.y = 66
        })
    }
    
    func filterContentForSearchText(searchText:String) {
        if inRefreshing {
            return
        }
        
        if searchText == "" {
            moviesFiltered = movies
        }
        else {
            moviesFiltered = movies.filter{movie in return (movie["title"] as! String).lowercased().contains(searchText.lowercased())}
        }
        
        if showTypeSegmentedControl.selectedSegmentIndex == 0 {
            tableView.reloadData()
        }
        else {
            collectionView.reloadData()
        }
        
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true;
        tapGesture.isEnabled = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText: searchText)
    }
    
    func changeShowType() {
        searchBar.text = ""
        searchActive = false
        searchBar.endEditing(true)
        
        if showTypeSegmentedControl.selectedSegmentIndex == 0 {
            tableView.isHidden = false
            tableView.reloadData()
            collectionView.isHidden = true
        } else {
            tableView.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        }
    }

    func refreshControlAction(refreshControl: UIRefreshControl) {
        if searchActive || (searchBar.text?.characters.count)! > 0 {
            searchActive = false
            searchBar.endEditing(true)
            tapGesture.isEnabled = false
            refreshControl.endRefreshing()
            return
        }
        
        inRefreshing = true
        MOHUD.show()
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request, completionHandler: {
            (data, response, error) in
            
            if let newData = data {
                if let responseDictionary = try! JSONSerialization.jsonObject(
                    with: newData, options:[]) as? NSDictionary {
                    print("new data loaded")
                    self.movies = responseDictionary["results"] as! [NSDictionary]
                    self.moviesFiltered = self.movies
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    self.hideNetworkError()
                }
            }
            else {
                self.showNetworkError()
            }
            
            refreshControl.endRefreshing()
            MOHUD.hideAfter(0.3)
            
            self.inRefreshing = false
        });
        task.resume()
    }
    
    func loadMovies() {
        MOHUD.show()
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = URLRequest(
            url: url!,
            cachePolicy: NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main
        )
        let task: URLSessionDataTask =
            session.dataTask(with: request,
                             completionHandler: { (dataOrNil, response, error) in
                                if let data = dataOrNil {
                                    if let responseDictionary = try! JSONSerialization.jsonObject(
                                        with: data, options:[]) as? NSDictionary {
                                        print("data loaded")
                                        self.movies = responseDictionary["results"] as! [NSDictionary]
                                        self.moviesFiltered = self.movies
                                        self.tableView.reloadData()
                                        self.collectionView.reloadData()
                                        self.hideNetworkError()
                                    }
                                }
                                else {
                                    self.showNetworkError()
                                }
                                MOHUD.hideAfter(0.3)
            })
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRow = movies.count
        if searchActive {
            numberOfRow = moviesFiltered.count
        }
        return numberOfRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieTableViewCell
        
        var moviesSource = movies
        if searchActive {
            moviesSource = moviesFiltered
        }
        
        cell.titleLabel.text = moviesSource[indexPath.row]["title"] as? String
        cell.overviewLabel.text = moviesSource[indexPath.row]["overview"] as? String
        if let posterPath = moviesSource[indexPath.row]["poster_path"] as? String {
            cell.posterImageView.alpha = 0
            cell.titleLabel.alpha = 0
            cell.overviewLabel.alpha = 0
            
            let smallImageRequest = NSURLRequest(url: NSURL(string: baseUrlLow + posterPath)! as URL)
            let largeImageRequest = NSURLRequest(url: NSURL(string: baseUrlHigh + posterPath)! as URL)
            
            cell.posterImageView.setImageWith(smallImageRequest as URLRequest, placeholderImage: nil,
                                              success: { (smallImageRequest, smallImageResponse, smallImage) -> Void in
                                                UIView.animate(withDuration: 0.6, animations: { () -> Void in
                                                    cell.posterImageView.alpha = 1
                                                }, completion: { (sucess) -> Void in
                                                    
                                                    cell.posterImageView.setImageWith(
                                                        largeImageRequest as URLRequest,
                                                        placeholderImage: smallImage,
                                                        success: { (largeImageRequest, largeImageResponse, largeImage) -> Void in
                                                            
                                                            cell.posterImageView.image = largeImage;
                                                            
                                                        },
                                                        failure: { (request, response, error) -> Void in
                                                            // do something for the failure condition of the large image request
                                                            // possibly setting the ImageView's image to a default image
                                                    })
                                                    
                                                })
                }, failure: nil)
            
            
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                cell.titleLabel.alpha = 1
                cell.overviewLabel.alpha = 1
            })
        }
        else {
            cell.posterImageView.image = nil
        }
        
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfRow = movies.count
        if searchActive {
            numberOfRow = moviesFiltered.count
        }
        return numberOfRow
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionCell", for: indexPath) as! MovieCollectionViewCell
        
        var moviesSource = movies
        if searchActive {
            moviesSource = moviesFiltered
        }
        
        if let ratedPoint = moviesSource[indexPath.row]["vote_average"] as? Double {
            cell.voteRatedLabel.text = "\(ratedPoint)"
        }
        else {
            cell.voteRatedLabel.text = "N/A"
        }
        if let posterPath = moviesSource[indexPath.row]["poster_path"] as? String {
            cell.posterImageView.alpha = 0
            cell.posterImageView.setImageWith(URL(string: baseUrlLow + posterPath)!)
            UIView.animate(withDuration: 0.9, animations: { () -> Void in
                cell.posterImageView.alpha = 1
            })
        }
        else {
            cell.posterImageView.image = nil
        }
        
        return cell
    }
    
    @IBAction func endTypingInSearchTextbox(_ sender: AnyObject) {
        searchBar.endEditing(true)
        tapGesture.isEnabled = false
    }
    @IBAction func swipedEndTypingSearchTextbox(_ sender: AnyObject) {
        print("Swipe up")
        searchBar.endEditing(true)
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let destinationViewController = segue.destination as! DetailsViewController
        
        var moviesSource = movies
        if searchBar.text != "" {
            moviesSource = moviesFiltered
        }
        
        if showTypeSegmentedControl.selectedSegmentIndex == 0 {
            destinationViewController.movie = moviesSource[(tableView.indexPathForSelectedRow?.row)!]
        }
        else {
            destinationViewController.movie = moviesSource[(collectionView.indexPath(for: sender as! UICollectionViewCell)?.row)!]
        }
    }
}
