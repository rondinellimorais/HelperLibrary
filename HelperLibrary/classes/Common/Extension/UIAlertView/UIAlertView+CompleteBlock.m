//
//  Copyright (c) 2012 Rondinelli Morais. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the
//  Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "UIAlertView+CompleteBlock.h"
#import <objc/runtime.h>

const char * saveObjectsKey = "saveObjects";
static NSString * completeBlockkey = @"completeBlock";

@implementation UIAlertView (CompleteBlock)

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                completeBlock:(void(^)(UIAlertView * alertView, NSInteger buttonIndex))completeBlock
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... {
    
    // sava os objetos que serão usado mais tarde
    NSDictionary * dictionarySaveObjects = [NSDictionary dictionaryWithObjects:@[completeBlock] forKeys:@[completeBlockkey]];
    objc_setAssociatedObject(self, saveObjectsKey, dictionarySaveObjects, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    // adiciona os botoes
    NSMutableArray * arrOtherButtonTitles = [NSMutableArray array];
    if(otherButtonTitles) {
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*)){
            [arrOtherButtonTitles addObject:arg];
        }
        va_end(args);
    }
    
    // configura o primeiro botão, se não fizer isso o delegate não funcinoa
    NSString * firstButtonOtherButtonTitle = nil;
    if(arrOtherButtonTitles && arrOtherButtonTitles.count > 0){
        firstButtonOtherButtonTitle = [arrOtherButtonTitles firstObject];
        [arrOtherButtonTitles removeObjectAtIndex:0];
    }
    
    // inicializa o objeto
    self =  [self initWithTitle:title
                        message:message
                       delegate:self
              cancelButtonTitle:cancelButtonTitle
              otherButtonTitles:firstButtonOtherButtonTitle, nil];
    
    if(self)
    {
        // adiciona demais botoes
        if(arrOtherButtonTitles && arrOtherButtonTitles.count > 0) {
            for (NSString * btnTitle in arrOtherButtonTitles) {
                [self addButtonWithTitle:btnTitle];
            }
        }
    }

    return self;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSDictionary * dictionarySaveObjects = objc_getAssociatedObject(self, saveObjectsKey);
    
    void(^completeBlock)(UIAlertView * alertView, NSInteger buttonIndex) = [dictionarySaveObjects objectForKey:completeBlockkey];
    
    completeBlock(alertView, buttonIndex);
}

@end
