//
//  ViewController.swift
//  AKSwitch
//
//  Created by Arun Kumar Pattanayak on 17/03/17.
//  Copyright © 2017 Arun Kumar Pattanayak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var switchBtn : AKSwitch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let screenFrame  = UIScreen.main.bounds
        
        
        switchBtn = AKSwitch(size: .normal, style: .defaultStyle, state: .off)
        switchBtn?.center = CGPoint(x: CGFloat(screenFrame.size.width * 6 / 7), y: CGFloat(45))
        switchBtn?.addTarget(self, action: #selector(self.stateChanged), for: .valueChanged)
        self.view.addSubview(switchBtn!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func stateChanged() {
        if switchBtn?.isOn == true {
            print("on")
        }
        else {
            print("off")
        }
    }

}

