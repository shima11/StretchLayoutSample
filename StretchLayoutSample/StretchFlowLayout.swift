//
//  StretchFlowLayout.swift
//  StretchLayoutSample
//
//  Created by shima jinsei on 2017/01/24.
//  Copyright © 2017年 Jinsei Shima. All rights reserved.
//

import Foundation
import UIKit

class StretchFlowLayout: UICollectionViewFlowLayout {
    
    var bufferedContentInsets: UIEdgeInsets!
    var transformsNeedReset: Bool = false
    var scrollResistanceDenominator: CGFloat = 0.0
    var contentOverflowPadding: UIEdgeInsets!
    
    override var collectionViewContentSize: CGSize {
        var contentSize = super.collectionViewContentSize
        contentSize.height += self.contentOverflowPadding.top + self.contentOverflowPadding.bottom
        return contentSize
    }
    
    override init(){
        super.init()
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    private func setup() {
        self.minimumInteritemSpacing = 10
        self.minimumLineSpacing = 10
        self.itemSize = CGSize(width: 320, height: 60)
        self.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0)
        self.scrollResistanceDenominator =  500
        self.contentOverflowPadding = UIEdgeInsetsMake(100, 0, 100, 0)
        self.bufferedContentInsets = self.contentOverflowPadding
        self.bufferedContentInsets.top *= -1
        self.bufferedContentInsets.bottom *= -1
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let rect = UIEdgeInsetsInsetRect(rect, self.bufferedContentInsets)
        let items = super.layoutAttributesForElements(in: rect)
        for item in items! {
            var center: CGPoint = item.center
            center.y += self.contentOverflowPadding.top
            item.center = center
        }
        let collectionViewHeight:CGFloat = super.collectionViewContentSize.height
        let topOffset:CGFloat = self.contentOverflowPadding.top
        let bottomOffset: CGFloat = collectionViewHeight - (self.collectionView?.frame.size.height)! + self.contentOverflowPadding.top
        let yPosition: CGFloat = (self.collectionView?.contentOffset.y)!
        
        if (yPosition < topOffset) {
            let stretchDelta: CGFloat = topOffset - yPosition
            for item in items! {
                let distanceFromTop = item.center.y - self.contentOverflowPadding.top
                let scrollResistane = distanceFromTop / self.scrollResistanceDenominator
                item.transform = CGAffineTransform(translationX: 0, y: -stretchDelta + (stretchDelta * scrollResistane))
            }
            self.transformsNeedReset = true
        } else if (yPosition > bottomOffset) {
            let stretchDelta = yPosition - bottomOffset
            for item in items! {
                let distanceFromBottom: CGFloat = collectionViewHeight + self.contentOverflowPadding.top
                    - item.center.y
                let scrollResistance: CGFloat = distanceFromBottom / self.scrollResistanceDenominator
                item.transform = CGAffineTransform(translationX: 0, y: stretchDelta + (-stretchDelta * scrollResistance))
                self.transformsNeedReset = true
            }
        } else if (self.transformsNeedReset) {
            self.transformsNeedReset = false
            for item in items! {
                item.transform = CGAffineTransform.identity
            }
        }
        
        return items
    }
    
}
