#import <UIKit/UIKit.h>
#import <dlfcn.h>

// Maklumat API yang baru kamu bagi
static NSString *name = @"azuriteadmin"; 
static NSString *ownerid = @"8z9qsAXGks";
static NSString *secret = @"fea6acbf1b1ef751775c6e12882d8dc1ffb5f264707b7428375e37ed11186697";

void bukaPanelAzurite() {
    // CUBA LOAD DENGAN SELAMAT
    void *handle = dlopen("azurite.dylib", RTLD_LAZY);
    
    if (!handle) {
        // JIKA FAIL TAK JUMPA, KELUARKAN ALERT SAJA (JANGAN CRASH!)
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
            if (!keyWindow && [[UIApplication sharedApplication] windows].count > 0) {
                keyWindow = [[UIApplication sharedApplication] windows][0];
            }
            
            UIAlertController *err = [UIAlertController alertControllerWithTitle:@"INFO" 
                                     message:@"Login Berjaya! Tapi azurite.dylib tak jumpa. Anda tersalah inject fail .deb tadi." 
                                     preferredStyle:UIAlertControllerStyleAlert];
            [err addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [keyWindow.rootViewController presentViewController:err animated:YES completion:nil];
        });
        return;
    }
}

void validateWithKeyAuth(NSString *userKey) {
    if (!userKey || userKey.length == 0) return;

    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *urlStr = [NSString stringWithFormat:@"https://keyauth.win/api/1.1/?type=login&name=%@&ownerid=%@&secret=%@&version=1.0&key=%@&hwid=%@", 
                        name, ownerid, secret, userKey, hwid];
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (json && [json[@"success"] boolValue]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    bukaPanelAzurite();
                });
            } else {
                // Key salah takpa, kita biar saja atau exit(0)
                exit(0);
            }
        }
    }] resume];
}

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        if (!keyWindow && [[UIApplication sharedApplication] windows].count > 0) {
            keyWindow = [[UIApplication sharedApplication] windows][0];
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AZURITE LOGIN" 
                                       message:@"Masukkan Key Anda" 
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"License Key";
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            validateWithKeyAuth(alert.textFields.firstObject.text);
        }]];
        
        [keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLogin();
    });
}
