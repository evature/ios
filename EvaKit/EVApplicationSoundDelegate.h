//
//  EVApplicationSoundDelegate.h
//  EvaKit
//
//  Created by Iftah Haimovitch on 31/01/2016.
//  Copyright © 2016 Evature. All rights reserved.
//

#ifndef EVApplicationSoundDelegate_h
#define EVApplicationSoundDelegate_h

@class EVApplicationSound;

@protocol EVApplicationSoundDelegate <NSObject>

-(void)didFinishPlay:(EVApplicationSound*)sound;
@end


#endif /* EVApplicationSoundDelegate_h */
