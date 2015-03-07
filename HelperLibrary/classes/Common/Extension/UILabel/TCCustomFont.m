#import <UIKit/UIKit.h>

@interface UIButton (TCCustomFont)
@property (nonatomic, copy) NSString* fontName;
@end

@implementation UIButton (TCCustomFont)

- (NSString *)fontName {
    return self.titleLabel.font.fontName;
}

- (void)setFontName:(NSString *)fontName {
    self.titleLabel.font = [UIFont fontWithName:fontName size:self.titleLabel.font.pointSize];
}

@end

@interface UILabel (TCCustomFont)
@property (nonatomic, copy) NSString* fontName;
@end

@implementation UILabel (TCCustomFont)

- (NSString *)fontName {
    return self.font.fontName;
}

- (void)setFontName:(NSString *)fontName {
    self.font = [UIFont fontWithName:fontName size:self.font.pointSize];
}

@end


@interface UITextField (TCCustomFont)
@property (nonatomic, copy) NSString* fontName;
@end

@implementation UITextField (TCCustomFont)

- (NSString *)fontName {
    return self.font.fontName;
}

- (void)setFontName:(NSString *)fontName {
    self.font = [UIFont fontWithName:fontName size:self.font.pointSize];
}

@end