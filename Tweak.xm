#import <UIKit/UIKit.h>
#import <string>

// Kita buang #include "skCrypt.h" supaya tak ralat lagi

using namespace std;

void validateWithKeyAuth(NSString *userKey) {
    if (!userKey || userKey.length == 0) return;

    // Guna string biasa tanpa skCrypt
    string name = "azuriteadmin"; 
    string ownerid = "8z9qsAXGks"; 
    string secret = "fea6acbf1b1ef751775c6e12882d8dc1ffb5f264707b7428375e37ed11186697";
    string version = "1.0"; 
    string apiAddr = "https://keyauth.win/api/1.1/";

    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *urlRaw = [NSString stringWithFormat:@"%s?type=login&name=%s&ownerid=%s&secret=%s&version=%s&key=%@&hwid=%@", 
                        apiAddr.c_str(), name.c_str(), ownerid.c_str(), secret.c_str(), version.c_str(), userKey, hwid];
    
    NSURL *url = [NSURL URLWithString:[urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data && !error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (json && [json[@"success"] boolValue]) {
                    NSLog(@"[Azurite] Success!");
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
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLogin();
    });
}
