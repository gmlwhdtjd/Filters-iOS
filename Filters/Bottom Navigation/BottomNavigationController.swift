//
//  BottomNavigationController.swift
//  Filters
//
//  Created by Hui Jong Lee on 2018. 8. 25..
//  Copyright © 2018년 Hui Jong Lee. All rights reserved.
//

import UIKit

class BottomNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
}

// MARK: - UINavigationControllerDelegate for Animated Transitioning

extension BottomNavigationController: UINavigationControllerDelegate {
    class animatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.3
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let fromView = transitionContext.view(forKey: .from),
                let toView = transitionContext.view(forKey: .to) else {
                    return
            }
            
            let onRect = fromView.frame
            let offRect = CGRect(x: onRect.minX, y: onRect.maxY, width: onRect.width, height: onRect.height)
            
            toView.frame = offRect
            toView.alpha = 0.0
            
            transitionContext.containerView.addSubview(toView)
            
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                toView.frame = onRect
                toView.alpha = 1.0
                
                fromView.frame = offRect
                fromView.alpha = 0.0
            }, completion: { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animatedTransitioning()
    }
}
