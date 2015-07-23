//
//  EVCollectionViewFlowLayout.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/20/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCollectionViewFlowLayout.h"
#import "EVVoiceChatViewController.h"

@interface EVCollectionViewFlowLayout () {
    NSInteger lastAddedElement;
}

@end

@implementation EVCollectionViewFlowLayout

- (instancetype)init {
    self = [super init];
    if (self != nil) {
        lastAddedElement = -1;
    }
    return self;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attrs = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    if (lastAddedElement < itemIndexPath.row) {
        lastAddedElement = itemIndexPath.row;
        EVVoiceChatViewController* controller = (EVVoiceChatViewController*)self.collectionView.dataSource;
        if ([controller isMyMessageInRow:itemIndexPath.row]) {
            attrs.transform3D = CATransform3DMakeTranslation(self.collectionView.bounds.size.width, 0, 0);
        } else {
             attrs.transform3D = CATransform3DMakeTranslation(-self.collectionView.bounds.size.width, 0, 0);
        }
        
    }
    return attrs;
}

- (void)removedOneElement {
    lastAddedElement--;
}
- (void)removedAllElements {
    lastAddedElement = -1;
}

@end
