//
//  ViewController.swift
//  MastersDay3CustomCells
//
//  Created by Mark Wilkinson on 12/3/17.
//  Copyright © 2017 Mark Wilkinson. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "myCell") as? MyCell {
            let width = Int(cell.myImageView.frame.size.width)
            let height = Int(cell.myImageView.frame.size.width)
            let url = URL(string: "http://lorempixel.com/\(width)/\(height)")!
            cell.setImageWithURL(url: url, placeholder: nil)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
}

class MyCell : UITableViewCell {
    
    @IBOutlet weak var myImageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.cancelImageLoad()
        myImageView.image = nil
    }
    
    static var configuration: URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        return config
    }()
    
    static var session: URLSession = {
        let session = URLSession(
            configuration: MyCell.configuration,
            delegate: nil,
            delegateQueue: nil)
        session.delegateQueue.maxConcurrentOperationCount = 2
        return session
    }()
    
    var imageTask: URLSessionDataTask?
    
    func setImageWithURL(url: URL!, placeholder: UIImage? = nil) {
        imageTask?.cancel()
        imageTask = type(of: self).session.dataTask(with: url) { (data, response, error) in
            if error == nil {
                if let http = response as? HTTPURLResponse {
                    if http.statusCode == 200 {
                        
                        assert(!Thread.isMainThread, "called on main thread!")
                        
                        if (self.imageTask!.state == URLSessionTask.State.canceling) {
                            return
                        }
                        self.loadImageWithData(data: data!)
                    } else {
                        print("received an HTTP \(http.statusCode) downloading \(url)")
                    }
                } else {
                    print("Not an HTTP response")
                }
            } else {
                print("Error downloading image: \(url.path) -- \(error!.localizedDescription)")
            }
        }
        if let placeholderImage = placeholder {
            myImageView.image = placeholderImage
        }
        imageTask?.resume()
    }
    
    private func loadImageWithData(data: Data) {
        if let image = UIImage(data: data) {
            DispatchQueue.main.async {
                self.myImageView.image = image
//                let transition = CATransition()
//                transition.duration = 0.25
//                transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
//                transition.type = kCATransitionFade
//                self.layer.add(transition, forKey: nil)
            }
        }
    }
    
    func cancelImageLoad() {
        imageTask?.cancel()
    }
}

