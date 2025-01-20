//
//  ViewController.swift
//  VideoScroller
//
//  Created by Ashley Dsouza on 26/09/24.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var videoScrubber: VSVideoScrubber!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Task {
                
                videoScrubber.setupConfig()
                await videoScrubber.setup()
            }
    }


}

