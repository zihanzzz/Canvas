//
//  ViewController.swift
//  Canvas
//
//  Created by James Zhou on 11/2/16.
//  Copyright © 2016 James Zhou. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var trayView: UIView!
    
    var trayOriginalCenter: CGPoint!
    var trayCenterWhenOpen: CGPoint!
    var trayCenterWhenClosed: CGPoint!
    var newlyCreatedFace: UIImageView!
    
    var imageOriginalCenter: CGPoint!
    
    var faceOriginalCenter: CGPoint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.trayView.backgroundColor = UIColor.gray
        trayOriginalCenter = self.trayView.center
        trayCenterWhenOpen = CGPoint(x: self.trayView.center.x, y: self.trayView.center.y - 160)
        trayCenterWhenClosed = self.trayView.center
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onTrayTapGesture(_ sender: UITapGestureRecognizer) {
        if trayView.center.y == trayCenterWhenClosed.y {
            expandTray()
        } else {
            retractTray()
        }
    }
    @IBAction func onTrayPanGesture(_ sender: UIPanGestureRecognizer) {
        
        // Absolute (x,y) coordinates in parent view (parentView should be
        // the parent view of the tray)
        
        
        if sender.state == .began {
//            print("Gesture began at: \(point)")
        } else if sender.state == .changed {
            
            let translation = sender.translation(in: self.view)
            trayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
            
//            print("Gesture changed at: \(point)")
        } else if sender.state == .ended {
            let velocity = sender.velocity(in: self.view)
            
            if (velocity.y > 0.0) {
                retractTray()
            } else {
                expandTray()
            }

            
//            print("Gesture ended at: \(point)")
        }
        
    }
    
    func retractTray() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.trayView.center = self.trayCenterWhenClosed
        }, completion: nil)
    }
    
    func expandTray() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.trayView.center = self.trayCenterWhenOpen
        }, completion: nil)
    }
    
    @IBAction func onImagePan(_ sender: UIPanGestureRecognizer) {
        
        
        
        switch sender.state {
        case .began:
            
            // Gesture recognizers know the view they are attached to
            let imageView = sender.view as! UIImageView
            
            // Create a new image view that has the same image as the one currently panning
            newlyCreatedFace = UIImageView(image: imageView.image)
            
            // Add the new face to the tray's parent view.
            view.addSubview(newlyCreatedFace)
            
            // Initialize the position of the new face.
            newlyCreatedFace.center = imageView.center
            
            // Since the original face is in the tray, but the new face is in the
            // main view, you have to offset the coordinates
            newlyCreatedFace.center.y += trayView.frame.origin.y
            
            imageOriginalCenter = newlyCreatedFace.center
            
            //create gesture recognizer
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(facePanned(_:)))
            panGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(panGestureRecognizer)
            
            let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(facePinched(_:)))
            pinchGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(pinchGestureRecognizer)
            
            newlyCreatedFace.isUserInteractionEnabled = true
            
            let rotateGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(faceRotated(_:)))
            rotateGestureRecognizer.delegate = self
            newlyCreatedFace.addGestureRecognizer(rotateGestureRecognizer)
            
            newlyCreatedFace.isMultipleTouchEnabled = true

            break
            
        case .changed:
            
            
            let translation = sender.translation(in: self.view)
            newlyCreatedFace.center = CGPoint(x: imageOriginalCenter.x + translation.x, y: imageOriginalCenter.y + translation.y)
            
            break
            
        default:
            break
        }
        
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func faceRotated(_ sender:UIRotationGestureRecognizer) {
        var transform = sender.view!.transform
        transform = transform.rotated(by: sender.rotation)
        sender.view!.transform = transform
        sender.rotation = 0

    }
    
    func facePinched(_ sender:UIPinchGestureRecognizer) {
        print("frame: \(sender.view?.frame)")
        let scale = sender.scale
        sender.scale = 1
        
        var transform = sender.view!.transform
        transform = transform.scaledBy(x: scale, y: scale)
        sender.view!.transform = transform
    }
    
    func facePanned(_ sender:UIPanGestureRecognizer) {
        
        
        switch sender.state {
        case .began:
            faceOriginalCenter = sender.view?.center
            
            sender.view?.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        case .changed:
            let translation = sender.translation(in: self.view)
            sender.view?.center = CGPoint(x: faceOriginalCenter.x + translation.x, y: faceOriginalCenter.y + translation.y)

        case .ended:
            sender.view?.transform = CGAffineTransform(scaleX: 1, y: 1)
        default:
            print("hi")
        }

        
    }
    

}

