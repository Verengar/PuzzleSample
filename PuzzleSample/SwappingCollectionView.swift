	
import UIKit

extension UIView {
    
    func snapshot() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

extension CGPoint {
    func distanceToPoint(_ p:CGPoint) -> CGFloat {
        return sqrt(pow((p.x - x), 2) + pow((p.y - y), 2))
    }
}

struct SwapDescription : Hashable {
    var firstItem : Int
    var secondItem : Int
    
    var hashValue: Int {
        get {
            return firstItem + secondItem
        }
    }
}

func ==(lhs: SwapDescription, rhs: SwapDescription) -> Bool {
    return lhs.firstItem == rhs.firstItem && lhs.secondItem == rhs.secondItem
}

class SwappingCollectionView: UICollectionView {
    
    var interactiveIndexPath : IndexPath?
    var interactiveView : UIView?
    var interactiveCell : UICollectionViewCell?
    var swapSet : Set<SwapDescription> = Set()
    var previousPoint : CGPoint?
    var point : IndexPath = []
    static let distanceDelta:CGFloat = 2
    var inter : IndexPath = []
    var pointCG : CGPoint?
    
    override func beginInteractiveMovementForItem(at indexPath: IndexPath) -> Bool {
        
        self.interactiveIndexPath = indexPath
        inter = indexPath
        self.interactiveCell = self.cellForItem(at: indexPath)
        self.interactiveView = UIImageView(image: self.interactiveCell?.snapshot())
        self.interactiveView?.frame = self.interactiveCell!.frame
        
        self.addSubview(self.interactiveView!)
        self.bringSubview(toFront: self.interactiveView!)
        
        self.interactiveCell?.isHidden = true
        
        return true
    }
    
    override func updateInteractiveMovementTargetPosition(_ targetPosition: CGPoint) {
        
        
        if let hoverIndexPath = self.indexPathForItem(at: targetPosition), let interactiveIndexPath = self.interactiveIndexPath {
            point = hoverIndexPath
            pointCG = targetPosition
            let swapDescription = SwapDescription(firstItem: interactiveIndexPath.item, secondItem: hoverIndexPath.item)
            if (!self.swapSet.contains(swapDescription)) {
                self.swapSet.insert(swapDescription)
            
            }
        }
        
        self.interactiveView?.center = targetPosition
        self.previousPoint = targetPosition
    }
    
    override func endInteractiveMovement() {
        if (self.shouldSwap(pointCG!)) {
        let swapDescription = SwapDescription(firstItem: inter.item, secondItem: point.item)
        self.performBatchUpdates({
            self.moveItem(at: self.inter, to: self.point)
            self.moveItem(at: self.point, to: self.inter)
        }, completion: {(finished) in
            self.swapSet.remove(swapDescription)
            self.interactiveIndexPath = self.point
        })}
        
        self.cleanup()
    }
    
    
    
    override func cancelInteractiveMovement() {
     
        self.cleanup()
    }

    func cleanup() {
        self.interactiveCell?.isHidden = false
        self.interactiveView?.removeFromSuperview()
        self.interactiveView = nil
        self.interactiveCell = nil
        self.interactiveIndexPath = nil
        self.previousPoint = nil
        self.swapSet.removeAll()
    }
    
    func shouldSwap(_ newPoint: CGPoint) -> Bool {
        if let previousPoint = self.previousPoint {
            let distance = previousPoint.distanceToPoint(newPoint)
            return distance < SwappingCollectionView.distanceDelta
        }
        
        return false
    }
}
