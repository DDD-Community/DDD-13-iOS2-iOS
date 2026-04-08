//
//  UINavigationController+gesture.swift
//  DesignSystem
//
//  Created by DDD-iOS2 on 4/7/26.
//

import UIKit

extension UINavigationController: UIKit.UIGestureRecognizerDelegate {
  override open func viewDidLoad() {
    super.viewDidLoad()
    
    interactivePopGestureRecognizer?.delegate = self
  }
  
  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return viewControllers.count > 1
  }
}
