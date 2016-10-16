//
//  DetailsViewController.swift
//  MyMovies
//
//  Created by Duy Huynh Thanh on 10/12/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit
import AFNetworking
import ARSLineProgress
import MOHUD

class DetailsViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var inforView: UIView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var voteRatedLabel: UILabel!

    var movie:NSDictionary?
    var baseUrl = "http://image.tmdb.org/t/p/w342"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadMovieDetails()
        
        inforView.frame.size.height = titleLabel.frame.height + overviewLabel.frame.height + 70
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height + overviewLabel.frame.size.height)
    }
    
    func loadMovieDetails() {
        releaseDateLabel.text = movie?["release_date"] as? String
        if let ratedPoint = movie?["vote_average"] as? Double {
            voteRatedLabel.text = "\(ratedPoint)"
        }
        else {
            voteRatedLabel.text = "N/A"
        }
        
        titleLabel.text = movie?["title"] as? String
        overviewLabel.text = movie?["overview"] as? String
        overviewLabel.sizeToFit()
        if let posterPath = movie?["poster_path"] as? String {
            self.posterImageView.alpha = 0
            self.posterImageView.setImageWith(URL(string: baseUrl + posterPath)!)
            UIView.animate(withDuration: 0.9, animations: { () -> Void in
                self.posterImageView.alpha = 1
            })
        }
        else {
            posterImageView.image = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedOnPosterImageView(_ sender: AnyObject) {
        
        if inforView.alpha == 0 {
            self.posterImageView.contentMode = .scaleAspectFill
            UIView.animate(withDuration: 0.8, animations: {
                self.inforView.alpha = 0.7
                self.navigationController?.setNavigationBarHidden(false, animated: true)
                self.tabBarController?.tabBar.isHidden = false
                self.posterImageView.frame.origin.y = 63
                self.posterImageView.frame.size.height = 555
                
                self.view.backgroundColor = UIColor(colorLiteralRed: 205/255, green: 254/255, blue: 158/255, alpha: 1)
            })
        }
        else {
            UIView.animate(withDuration: 0.8, animations: {
                self.inforView.alpha = 0
                self.navigationController?.setNavigationBarHidden(true, animated: true)
                self.tabBarController?.tabBar.isHidden = true
                self.posterImageView.frame.origin.y = 0
                self.posterImageView.frame.size.height = 667
                
                self.view.backgroundColor = UIColor.black
            })
            self.posterImageView.contentMode = .scaleAspectFit
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
