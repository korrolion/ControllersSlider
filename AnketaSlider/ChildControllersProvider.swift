//
//  ChildControllersProvider.swift
//  AnketaSlider
//
//  Created by Igor Korolev on 15.09.16.
//  Copyright © 2016 Igor Korolev. All rights reserved.
//

import UIKit

class ChildControllersProvider: MBControllersProvider {
    private static let list: [UIColor] = [
        .green,
        .yellow,
        .red,
        .orange,
        .blue,
        .black,
        .white,
        .cyan,
        .magenta,
        .purple,
    ]
    
    private var currentIndex: Int
    
    private var prevController: UIViewController?
    private var currentController: UIViewController
    private var nextController: UIViewController?
    
    init?(index: Int) {
        guard index >= 0 && index < ChildControllersProvider.list.count else { return nil }
        self.currentIndex = index
        self.currentController = ChildViewController.instance(color: ChildControllersProvider.list[index])
        if index > 0 {
            self.prevController = ChildViewController.instance(color: ChildControllersProvider.list[index - 1])
        }
        if index < ChildControllersProvider.list.count - 1 {
            self.nextController = ChildViewController.instance(color: ChildControllersProvider.list[index + 1])
        }
        
    }
    
    
    func provideCurrent() -> UIViewController? {
        return self.currentController
    }
    
    func providePrev() -> UIViewController? {
        return self.prevController
    }
    
    func provideNext() -> UIViewController? {
        return self.nextController
    }
    
    func setPrev() {
        guard currentIndex > 0 && currentIndex < ChildControllersProvider.list.count else { return }
        guard let prevController = prevController else { return }
        currentIndex -= 1
        nextController = currentController
        currentController = prevController
        self.prevController = currentIndex > 0 ? ChildViewController.instance(color: ChildControllersProvider.list[currentIndex - 1]) : nil
    }
    
    func setNext() {
        guard currentIndex >= 0 && currentIndex < ChildControllersProvider.list.count - 1 else { return }
        guard let nextController = nextController else { return }
        currentIndex += 1
        prevController = currentController
        currentController = nextController
        self.nextController = currentIndex < ChildControllersProvider.list.count - 1 ? ChildViewController.instance(color: ChildControllersProvider.list[currentIndex + 1]) : nil
    }
    
}
