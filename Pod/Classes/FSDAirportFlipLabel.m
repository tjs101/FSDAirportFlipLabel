//
//  AirportFlipLabel.m
//  MyAnimations
//
//  Created by Felix Dumit on 3/25/14.
//  Copyright (c) 2014 Felix Dumit. All rights reserved.
//

#import "FSDAirportFlipLabel.h"
#import <AVFoundation/AVFoundation.h>

@interface FSDAirportFlipLabel () {
    NSInteger labelsInFlip;
}

@property (strong, nonatomic) NSMutableArray *labels;

@end

@implementation FSDAirportFlipLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self baseInit];
    }
    return self;
}

- (void)baseInit {
    self.textColor = [UIColor clearColor];
    self.labels = [[NSMutableArray alloc] init];
    self.useSound = YES;
    self.fixedLenght = -1;
    self.flipDuration = 0.1;
    self.flipDurationRange = 1.0;
    self.numberOfFlips = 10;
    self.numberOfFlipsRange = 1.0;
    self.flipBackGroundColor = [UIColor colorWithRed:0.157 green:0.161 blue:0.165 alpha:1.000];
    self.flipTextColor = [UIColor whiteColor];
    
    
    if (self.textSize == 0) {
        self.textSize = 14;
    }
    
    //[self updateText:self.text];
}

- (BOOL)flipping {
    return labelsInFlip > 0;
}

- (UILabel *)getOrCreateLabelForIndex:(NSInteger)index {
    CGRect frame = CGRectMake(self.bounds.origin.x + (self.textSize + 3) * index,
                              self.bounds.origin.y, self.textSize + 2, self.textSize + 2);
    
    UILabel *label;
    
    if (index < [self.labels count]) {
        label = [self.labels objectAtIndex:index];
    }
    else {
        label = [[UILabel alloc] init];
        
        [self.labels addObject:label];
        [self addSubview:label];
        
        label.backgroundColor = self.flipBackGroundColor;
        label.textColor = self.flipTextColor;
        label.textAlignment = NSTextAlignmentCenter;
    }
    
    label.frame = frame;
    label.font = [UIFont systemFontOfSize:self.textSize];
    
    return label;
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self updateText:text];
}

- (void)updateText:(NSString *)text {
    [self resetLabels];
    
    //    self.textSize = self.frame.size.width / text.length - 2;
    
    text = [text uppercaseString];
    
    NSInteger len = MAX(self.fixedLenght, text.length);
    
    for (NSInteger i = 0; i < len; i++) {
        // get ith label
        UILabel *label = [self getOrCreateLabelForIndex:i];
        
        // get ith character
        NSString *ichar = @"";
        
        if (i < [text length]) {
            ichar = [NSString stringWithFormat:@"%c", [text characterAtIndex:i]] ? : @"";
        }
        
        //if it is different than current animate flip
        label.hidden = [ichar isEqualToString:@""] && !self.fixedLenght > 0;
        
        if (![ichar isEqualToString:label.text]) {
            [self animateLabel:label
                      toLetter:ichar];
        }
        
        if (self.useSound && labelsInFlip == 1) {
//            [[FlipAudioPlayer sharedInstance] playFlipSound:0.1f / self.flipDuration];
        }
    }
}

- (void)resetLabels {
    labelsInFlip = 0;
    
    for (UILabel *label in self.labels) {
        label.hidden = YES;
    }
}

- (void)animateLabel:(UILabel *)label toLetter:(NSString *)letter {
    // only 1 flip for space
    labelsInFlip++;
    
    if ([letter isEqualToString:@" "] || [letter isEqualToString:@""]) {
        [self flipLabel:label
               toLetter:letter
        inNumberOfFlips:1];
    } else {
        // if it is the first label to start flipping, perform start block
        if (labelsInFlip == 1 && self.startedFlippingLabelsBlock) {
            self.startedFlippingLabelsBlock();
        }
        
        NSInteger extraFlips = (arc4random() % (NSInteger)(self.numberOfFlips * self.numberOfFlipsRange));
        // animate with between 10 to 20 flips
        [self flipLabel:label
               toLetter:letter
        inNumberOfFlips:self.numberOfFlips + extraFlips];
    }
}

- (NSString *)randomAlphabetCharacter {
    static NSString *const alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    
    return [NSString stringWithFormat:@"%C", [alphabet characterAtIndex:(arc4random() % alphabet.length)]];
}

- (void)flipLabel:(UILabel *)label toLetter:(NSString *)letter inNumberOfFlips:(NSInteger)flipsToDo {
    CGFloat duration = self.flipDuration + (drand48() * self.flipDurationRange * self.flipDuration);
    
    [UIView transitionWithView:label
                      duration:duration
                       options:UIViewAnimationOptionTransitionFlipFromTop
                    animations: ^{
                        label.text = flipsToDo == 1 ? letter : [self randomAlphabetCharacter];
                    }
     
                    completion: ^(BOOL finished) {
                        // if last flip
                        if (flipsToDo == 1) {
                            // label has set its final value, so it stopped flipping
                            labelsInFlip--;
                            
                            // if is is last 20% of labels, fade sound
                            if (labelsInFlip <= ceil(0.2 * self.text.length) && self.useSound) {
                                
                            }
                            
                            //if it is was last label flipping, perform finish block
                            if (labelsInFlip == 0) {
                                if (self.finishedFlippingLabelsBlock) {
                                    self.finishedFlippingLabelsBlock();
                                }
                                
                                if (self.useSound) {
                                    
                                }
                            }
                        } else {
                            [self flipLabel:label
                                   toLetter:letter
                            inNumberOfFlips:flipsToDo - 1];
                        }
                    }];
}


@end
