#ifndef __has_feature
#define __has_feature(x) 0
#endif
#ifndef __has_extension
#define __has_extension __has_feature // Compatibility with pre-3.0 compilers.
#endif

#if !(__has_feature(objc_arc) && __clang_major__ >= 3)
#error "MKSocialShareTableViewCell is designed to be used with ARC. Please add '-fobjc-arc' to the compiler flags of MKSocialShareTableViewCell.m."
#endif // __has_feature(objc_arc)


#import <Social/Social.h>
#import "SocialShareModal.h"


@implementation SocialShareModal

#pragma mark - Class Methods

+(BOOL)socialShareAvailable {
    
    if ( NSClassFromString(@"SLComposeViewController") != nil ) {
        BOOL facebookAvailable = [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
        BOOL twitterAvailable = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
        BOOL weiboAvailable = [SLComposeViewController isAvailableForServiceType:SLServiceTypeSinaWeibo];
        
        return ( facebookAvailable || twitterAvailable || weiboAvailable );
    }
    else {
        return NO;
    }
}


#pragma mark - Action Methods

-(void)sendFacebookMessage
{
    [self postMessageForServiceType:SLServiceTypeFacebook];
}

-(void)sendTwitterMessage
{
    [self postMessageForServiceType:SLServiceTypeTwitter];
}

-(void)sendWeiboMessage
{
    [self postMessageForServiceType:SLServiceTypeSinaWeibo];
}

-(void)postMessageForServiceType:(NSString*)inServiceType {
    SLComposeViewController* socialController = [SLComposeViewController composeViewControllerForServiceType:inServiceType];
    
    if ( nil != socialController ) {
        if ( nil != self.postText ) {
            [socialController setInitialText:self.postText];
        }
        
        if ( nil != self.postImageList ) {
            for (UIImage* image in self.postImageList ) {
                [socialController addImage:image];
            }
        }
        
        if ( nil != self.postURLList ) {
            for (NSURL* url in self.postURLList ) {
                [socialController addURL:url];
            }
        }
        
//        UIResponder* targetResponder = self.nextResponder;
//        if ( ![targetResponder isKindOfClass:[UIViewController class]] ) {
//            targetResponder = targetResponder.nextResponder;
//            
//            if (![targetResponder isKindOfClass:[UIViewController class]]) {
//                // uh oh
//                NSLog(@"Could not find MKSocialShareTableViewCell's owning view controller!");
//                return;
//            }
//        }
        
        //UIViewController* currentController = (UIViewController*)targetResponder;
        [self.targetViewController presentModalViewController:socialController animated:YES];
       
    }
}

@end
