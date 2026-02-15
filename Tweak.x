#import <UIKit/UIKit.h>

static NSString *name = @"azuriteadmin"; 
static NSString *ownerid = @"8z9qsAXGks";
static NSString *secret = @"fea6acbf1b1ef751775c6e12882d8dc1ffb5f264707b7428375e37ed11186697";

void validateWithKeyAuth(NSString *userKey) {
    if (!userKey || userKey.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{ exit(0); });
        return;
    }

    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *urlRaw = [NSString stringWithFormat:@"https://keyauth.win/api/1.1/?type=login&name=%@&ownerid=%@&secret=%@&version=1.0&key=%@&hwid=%@", name, ownerid, secret, userKey, hwid];
    NSString *urlEncoded = [urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // PEMBETULAN: Kod NSURLRequest yang betul untuk elak Error 2
    NSURL *requestURL = [NSURL URLWithString:urlEncoded];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data && !error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (json && [json[@"success"] boolValue]) {
                    NSLog(@"[Azurite] Login Berjaya!");
                } else {
                    exit(0); // Key salah terus FC
                }
            } else {
                exit(0); // Tiada internet terus FC
            }
        });
    }] resume];
}

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    window = windowScene.windows.firstObject;
                    break;
                }
            }
        }
        if (!window) window = [UIApplication sharedApplication].keyWindow;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AZURITE LOGIN" 
                                       message:@"Sila masukkan license key" 
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"License Key";
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            validateWithKeyAuth(alert.textFields.firstObject.text);
        }]];
        
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

%ctor {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *note) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            showLogin();
        });
    }];
}
