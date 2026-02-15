#import <UIKit/UIKit.h>
#import <string>
#include "skCrypt.h"

using namespace std;

void validateWithKeyAuth(NSString *userKey) {
    if (!userKey || userKey.length == 0) return;

    // Data API kamu
    string name = skCrypt("azuriteadmin").decrypt(); 
    string ownerid = skCrypt("8z9qsAXGks").decrypt(); 
    string secret = skCrypt("fea6acbf1b1ef751775c6e12882d8dc1ffb5f264707b7428375e37ed11186697").decrypt();
    string version = skCrypt("1.0").decrypt(); 
    string apiAddr = skCrypt("https://keyauth.win/api/1.1/").decrypt();

    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *urlRaw = [NSString stringWithFormat:@"%s?type=login&name=%s&ownerid=%s&secret=%s&version=%s&key=%@&hwid=%@", 
                        apiAddr.c_str(), name.c_str(), ownerid.c_str(), secret.c_str(), version.c_str(), userKey, hwid];
    
    NSURL *url = [NSURL URLWithString:[urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data && !error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (!(json && [json[@"success"] boolValue])) {
                    exit(0);
                }
            } else {
                exit(0);
            }
        });
    }] resume];
}

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Cara cari window yang lebih selamat untuk elakkan ralat deprecated
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

        if (window && window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AZURITE" 
                                           message:@"Enter License Key" 
                                           preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:nil];
            [alert addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                validateWithKeyAuth(alert.textFields.firstObject.text);
            }]];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLogin();
    });
}
