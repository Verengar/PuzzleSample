//
//  ViewController.swift
//  PuzzleSample
//
//  Created by Admin on 05.09.2017.
//  Copyright © 2017 Łukasz Stoiński. All rights reserved.
//

import UIKit

extension UIView {
    
    func dropShadow() {
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = self.layer.frame.height/5
        
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        
        self.layer.rasterizationScale = UIScreen.main.scale
        
    }
}
extension UIImage {
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let valueWidth = 4
    var array = Array(0...15)
    let image = UIImage(named:"dog.jpg")
    var tapPressGesture : UIPanGestureRecognizer?
    @IBOutlet weak var collectionView: SwappingCollectionView!
    @IBOutlet weak var collectionViewBackgroundView: UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cropImages()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "CustomCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CustomCell")
        self.tapPressGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleLongGesture(_:)))
        self.collectionView?.addGestureRecognizer(tapPressGesture!)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func cropImages(){
        var imageNumber = 1
        var sum1 = 0
        for i in 1...valueWidth
        {
            let width = image?.size.width
            sum1 += i
            
            var sum2 = 0
            
            for b in 1...valueWidth
            {
                let imageDest = image?.crop(rect: CGRect(x: (CGFloat(b-1)/CGFloat(valueWidth)*width!), y: (CGFloat(i-1)/CGFloat(valueWidth)*width!), width: width!/CGFloat(valueWidth), height: width!/CGFloat(valueWidth)))
                let fileManager = FileManager.default
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("img\(imageNumber)")
                print(paths)
                let imageData = UIImageJPEGRepresentation(imageDest!, 0.5)
                fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
                imageNumber = imageNumber + 1
                sum2 += b
                
                
            }
        }}



    func handleLongGesture(_ gesture: UIPanGestureRecognizer) {
            
        switch(gesture.state) {
                
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView?.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
            }
            collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            collectionView?.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            collectionView?.endInteractiveMovement()
            checkAnswer()
        default:
            collectionView?.cancelInteractiveMovement()
            }
        }

        
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let screenWidth = (collectionView.frame.width)
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0 )
        layout.itemSize = CGSize(width: screenWidth/CGFloat(valueWidth), height: screenWidth/CGFloat(valueWidth))
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionViewBackgroundView.layer.cornerRadius = 3
        collectionViewBackgroundView.dropShadow()
    
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return valueWidth*valueWidth
        
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let tCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        tCell.imageView.image = nil
        let arrayKey = Int(arc4random_uniform(UInt32(array.count)))
        let randNum = array[arrayKey]
        array.remove(at: arrayKey)
        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent("img\(randNum + 1)")
        tCell.imageView.image = UIImage(contentsOfFile: imagePAth)
        tCell.textLabel.text = String(randNum + 1)
        return tCell
      
    }
    func checkAnswer() {
        var boolek = true
        for subView in collectionView.subviews {
                
            if subView is CustomCell {
                let currentCell = self.collectionView.indexPath(for: subView as! UICollectionViewCell)
                let Cell = collectionView.cellForItem(at: currentCell!) as! CustomCell
                    
                if String((currentCell?.row)! + 1) != Cell.textLabel.text {
                    boolek = false
                    break
                        
                }
                else{
                        
                }
                    
            }
                
            }
        if boolek {
            congratulationAlert()
            }
        }
        
    func congratulationAlert(){
        tapPressGesture?.isEnabled = false
        let alertController = UIAlertController(title: "Congratulations!", message: "", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Restart", style: UIAlertActionStyle.default) {
        (result : UIAlertAction) -> Void in
        self.array = Array(0...15)
        self.tapPressGesture?.isEnabled = true
        self.collectionView.reloadData()
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        }
        
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

}

