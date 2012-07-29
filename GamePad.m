/*
 * GamePad: http://www.facebook.com/gamedevelopersnew
 *
 * Copyright (c) 2012-2013 Sam Fisher
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "GamePad.h"

@implementation GamePad (pvt)

@end

@implementation GamePad
@synthesize delegate_;
@synthesize upSelector,downSelector;
@synthesize tagCounter;


+(id)GamePadJoystickNormalSpriteFile:(NSString *)filename1 
		   selectedSpriteFile:(NSString *)filename2 
		 controllerSpriteFile:(NSString *)controllerSprite
                       buttonActionDelegate:(id)_delegate
{
    GamePad *gp = [GamePad joystickNormalSpriteFile:filename1 selectedSpriteFile:filename2 controllerSpriteFile:controllerSprite];
    gp.tagCounter = 1;
    gp.upSelector = [NSMutableArray array];
    gp.downSelector = [NSMutableArray array];
    gp.delegate_ = _delegate;
    
    return gp;
}
-(CCSprite*)configureButtonWithImage:(NSString*)img 
                     UpSelector:(SEL)upSEL 
                   DownSelector:(SEL)downSEL 
{
    CCSprite *button =[CCSprite spriteWithFile:img];
    
    if(button && downSelector && downSelector)
    {
        [self.upSelector addObject:[NSValue valueWithPointer:upSEL]];
        [self.downSelector addObject:[NSValue valueWithPointer:downSEL]];
        
        button.tag = self.tagCounter;
        [button setOpacity:200];
        
        self.tagCounter++;
        [self addChild:button z:200];        
        return button;
    }
    
    return nil;
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{

    isActivated = ![super ccTouchBegan:touch withEvent:event];
    CGPoint location	= [touch locationInView: [touch view]];
	location			= [[CCDirector sharedDirector] convertToGL:location];
    
    BOOL isButtonTraced = NO;
    //we want to check for buttons if joystick is not operating
    if(isActivated)
    {
        for(int i = 1; i < self.tagCounter; i++)
        {
            CCSprite *sp = (CCSprite*)[self getChildByTag:i];
            
            if(CGRectContainsPoint([sp boundingBox], location))
            {
                [sp setOpacity:255];
                [self.delegate_ performSelector:(SEL)[[self.downSelector objectAtIndex:i-1]pointerValue]];
                isButtonTraced = YES;
                break;
            }
        }
    }
    
    return YES;
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(isActivated)
        [self ccTouchEnded:touch withEvent:event];
    else
        [super ccTouchEnded:touch withEvent:event];
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {

    [super ccTouchEnded:touch withEvent:event];

    CGPoint location	= [touch locationInView: [touch view]];
	location			= [[CCDirector sharedDirector] convertToGL:location];

    if(isActivated)
    {
        for(int i = 1; i < self.tagCounter; i++)
        {
            CCSprite *sp = (CCSprite*)[self getChildByTag:i];
            
            if(CGRectContainsPoint([sp boundingBox], location))
            {
                [sp setOpacity:200];
                [self.delegate_ performSelector:(SEL)[[self.upSelector objectAtIndex:i-1] pointerValue]];
                break;
            }
        }
        isActivated = NO;
    }
}
@end
