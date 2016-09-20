//
//  ParentViewController.swift
//  AnketaSlider
//
//  Created by Igor Korolev on 15.09.16.
//  Copyright © 2016 Igor Korolev. All rights reserved.
//

import UIKit

class ParentViewController: UIViewController {
    
    //Коэффициент торможения для рассчета тормозного пути. 0.009842 - Легковой автомобиль на мокром снеге, 0.019685 - на укатанном снеге, 0.03937 - гололед
    private static let kDrag: CGFloat = 0.019685
    
    private let provider: MBControllersProvider? = ChildControllersProvider(index: 3)
    
    private enum Position {
        case left, right, center
    }

    
    private var velocity: CGPoint?
    
    private var constraintToLeftView: NSLayoutConstraint?
    private var constraintToRightView: NSLayoutConstraint?
    private var constraintToCurrentView: NSLayoutConstraint?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(ParentViewController.handleLeftEdge(recognizer:)))
        leftEdgePan.edges = .left
        leftEdgePan.delegate = self
        self.view.addGestureRecognizer(leftEdgePan)
        
        let rightEdgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(ParentViewController.handleRightEdge(recognizer:)))
        rightEdgePan.edges = .right
        rightEdgePan.delegate = self
        self.view.addGestureRecognizer(rightEdgePan)
        
        if let currentVC = provider?.provideCurrent() as? ChildViewController {
            displayChildController(childVC: currentVC, position: .center)
        }
        if let leftVC = provider?.providePrev() as? ChildViewController {
            displayChildController(childVC: leftVC, position: .left)
        }
        if let rightVC = provider?.provideNext() as? ChildViewController {
            displayChildController(childVC: rightVC, position: .right)
        }

    }
    
    dynamic private func handleLeftEdge(recognizer: UIPanGestureRecognizer) {
        guard let leftConstraint = constraintToLeftView, let currentConstraint = constraintToCurrentView  else { return }
        switch recognizer.state {
        case .changed:
            let pointX = recognizer.translation(in: recognizer.view).x
            changePosition(leftViewConstraint: leftConstraint, rightViewConstraint: currentConstraint, pointX: pointX)
            velocity = recognizer.velocity(in: recognizer.view)
        case .ended:
            let pointX = recognizer.translation(in: recognizer.view).x
            if let velocityX = velocity?.x, ParentViewController.caclTargetPoint(pointX: pointX, velocityX: velocityX) < view.frame.width / 2 {
                //возврат назад
                endSwipe(oldViewConstraint: leftConstraint, newViewConstraint: currentConstraint, positionForOld: .left, completion: nil)
            } else {
                endSwipe(oldViewConstraint: currentConstraint, newViewConstraint: leftConstraint, positionForOld: .right) {
                    if let right = self.provider?.provideNext() as? ChildViewController {
                        self.hideChildController(childVC: right)
                    }
                    self.provider?.setPrev()
                    
                    self.constraintToRightView = self.constraintToCurrentView
                    self.constraintToCurrentView = self.constraintToLeftView

                    
                    if let leftNew = self.provider?.providePrev() as? ChildViewController {
                        self.displayChildController(childVC: leftNew, position: .left)
                    }
                }
            }
        default:
            break
        }
    }
    
    dynamic private func handleRightEdge(recognizer: UIPanGestureRecognizer) {
        guard let rightConstraint = constraintToRightView, let currentConstraint = constraintToCurrentView  else { return }
        switch recognizer.state {
        case .changed:
            let pointX = self.view.frame.width + recognizer.translation(in: recognizer.view).x
            changePosition(leftViewConstraint: currentConstraint, rightViewConstraint: rightConstraint, pointX: pointX)
            velocity = recognizer.velocity(in: recognizer.view)
        case .ended:
            let pointX = self.view.frame.width + recognizer.translation(in: recognizer.view).x
            if let velocityX = velocity?.x, ParentViewController.caclTargetPoint(pointX: pointX, velocityX: velocityX) > view.frame.width / 2 {
                //возврат назад
                endSwipe(oldViewConstraint: rightConstraint, newViewConstraint: currentConstraint, positionForOld: .right, completion: nil)
            } else {
                endSwipe(oldViewConstraint: currentConstraint, newViewConstraint: rightConstraint, positionForOld: .left) {
                    if let left = self.provider?.providePrev() as? ChildViewController {
                        self.hideChildController(childVC: left)
                    }
                    self.provider?.setNext()
                    
                    self.constraintToLeftView = self.constraintToCurrentView
                    self.constraintToCurrentView = self.constraintToRightView
                    
                    if let rightNew = self.provider?.provideNext() as? ChildViewController {
                        self.displayChildController(childVC: rightNew, position: .right)
                    }
                }
            }
        default:
            break
        }
    }
    
    private func changePosition(leftViewConstraint: NSLayoutConstraint, rightViewConstraint: NSLayoutConstraint, pointX: CGFloat) {
        leftViewConstraint.constant = pointX - view.frame.width
        rightViewConstraint.constant = pointX
    }
    
    private func endSwipe(oldViewConstraint: NSLayoutConstraint, newViewConstraint: NSLayoutConstraint, positionForOld: Position, completion: (() -> Void)?) {
        newViewConstraint.constant = 0
        switch positionForOld {
        case .left:
            oldViewConstraint.constant = -self.view.frame.width
        case .right:
            oldViewConstraint.constant = self.view.frame.width
        default: break
        }
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) { result in
            if let completion = completion {
                completion()
            }
        }
    }
    
    private func displayChildController(childVC: ChildViewController, position: Position) {
        addChildViewController(childVC)
        self.view.addSubview(childVC.view)
        childVC.didMove(toParentViewController: self)
        
        addConstraints(toView: childVC.view, position: position)
    }
    
    private func hideChildController(childVC: ChildViewController) {
        childVC.willMove(toParentViewController: nil)
        childVC.view.removeFromSuperview()
        childVC.removeFromParentViewController()
    }
    
    private func addConstraints(toView: UIView, position: Position) {
        toView.translatesAutoresizingMaskIntoConstraints = false
       
        let constraintWidth = NSLayoutConstraint(item: toView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        let constraintHeight = NSLayoutConstraint(item: toView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
        let constraintTop = NSLayoutConstraint(item: toView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let constraintLeading = NSLayoutConstraint(item: toView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        
        switch position {
        case .left:
            constraintLeading.constant = -view.frame.width
            constraintToLeftView = constraintLeading
        case .center:
            constraintToCurrentView = constraintLeading
        case .right:
            constraintLeading.constant = view.frame.width
            constraintToRightView = constraintLeading
        }        
        
        view.addConstraints([constraintWidth, constraintHeight, constraintTop, constraintLeading])
    }
    
    //Вычислить точку остановки
    private static func caclTargetPoint(pointX: CGFloat, velocityX: CGFloat) -> CGFloat {
        return pointX + ParentViewController.kDrag * velocityX * abs(velocityX) // вторая скорость по модулю для сохранения знака скорости
    }
    
}

extension ParentViewController: UIGestureRecognizerDelegate {
}

