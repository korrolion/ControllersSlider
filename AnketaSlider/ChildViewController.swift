//
//  ChildViewController.swift
//  AnketaSlider
//
//  Created by Igor Korolev on 15.09.16.
//  Copyright © 2016 Igor Korolev. All rights reserved.
//

import UIKit

class ChildViewController: UIViewController {
    
    var color: UIColor {
        get {
            return self.view.backgroundColor ?? .white
        }
        set {
            self.view.backgroundColor = newValue
        }
    }
    
    static func instance(color: UIColor) -> ChildViewController {
        let inst = ChildViewController()
        inst.color = color
        
        return inst
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}
