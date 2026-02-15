#import <UIKit/UIKit.h>
#import <string>
#include "skCrypt.h"

using namespace std;

// Gunakan fungsi C++ yang bersih
void validateWithKeyAuth(NSString *userKey) {
    if (!userKey || userKey.length == 0) return;

    // Sediakan data menggunakan skCrypt
    string name = skCrypt("azuriteadmin").decrypt(); 
    string ownerid = skCrypt("8z9qsAXGks").decrypt(); 
    string secret = skCrypt("fea6acbf1b1ef751775c6e12882d8dc1ffb5f264707b7428375e37ed11186697").decrypt();
    string version = skCrypt("1.0").decrypt(); 
    string apiAddr = skCrypt("https://keyauth.win/api/1.1/").decrypt();

    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // Bina URL Request
    NSString *urlRaw = [NSString stringWithFormat:@"%s?type=login&name=%s&ownerid=%s&secret=%s&version=%s&key=%@&hwid=%@", 
                        apiAddr.c_str(), name.c_str(), ownerid.c_str(), secret.c_str(), version.c_str(), userKey, hwid];
    
    NSURL *url = [NSURL URLWithString:[urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data && !error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (json && [json[@"success"] boolValue]) {
                    // Berjaya
                } else {
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
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window && [UIApplication sharedApplication].windows.count > 0) 
            window = [UIApplication sharedApplication].windows[0];

        if (!window || !window.rootViewController) return;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AZURITE" 
                                       message:@"Enter Key" 
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:nil];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            validateWithKeyAuth(alert.textFields.firstObject.text);
        }]];
        
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

%ctor {
    // Delay 10 saat untuk elakkan crash masa startup
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLogin();
    });
}
