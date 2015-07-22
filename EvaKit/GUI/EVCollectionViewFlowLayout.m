//
//  EVCollectionViewFlowLayout.m
//  EvaKit
//
//  Created by Yegor Popovych on 7/20/15.
//  Copyright (c) 2015 Evature. All rights reserved.
//

#import "EVCollectionViewFlowLayout.h"

@implementation EVCollectionViewFlowLayout

- (void)prepareLayout {
    [super prepareLayout];
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    NSLog(@"prepareForCollectionViewUpdates: %@", updateItems);
    [super prepareForCollectionViewUpdates:updateItems];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attrs = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    attrs.transform3D = CATransform3DMakeTranslation(-self.collectionView.bounds.size.width, 0, 0);
    return attrs;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)elementIndexPath {
    return [super initialLayoutAttributesForAppearingSupplementaryElementOfKind:elementKind atIndexPath:elementIndexPath];
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingDecorationElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)decorationIndexPath {
    return [super initialLayoutAttributesForAppearingDecorationElementOfKind:elementKind atIndexPath:decorationIndexPath];
}


@end
