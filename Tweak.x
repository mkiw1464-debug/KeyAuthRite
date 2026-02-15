#import <UIKit/UIKit.h>
#import <dlfcn.h>

// Maklumat API KeyAuth Terkini
static NSString *name = @"azuriteadmin"; 
static NSString *ownerid = @"8z9qsAXGks";
static NSString *secret = @"fea6acbf1b1ef751775c6e12882d8dc1ffb5f264707b7428375e37ed11186697";
static NSString *version = @"1.0";

void bukaPanelAzurite() {
    // Pastikan fail .dylib (bukan .deb) sudah di-inject ke dalam IPA
    void *handle = dlopen("azurite.dylib", RTLD_LAZY);
    
    if (!handle) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *err = [UIAlertController alertControllerWithTitle:@"RALAT FAIL" 
                                     message:@"Login Berjaya! Tetapi fail 'azurite.dylib' tidak dijumpai. Anda mesti extract dylib dari fail .deb asal." 
                                     preferredStyle:UIAlertControllerStyleAlert];
            [err addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:err animated:YES completion:nil];
        });
        return;
    }
}

void validateWithKeyAuth(NSString *userKey) {
    if (!userKey || [userKey length] == 0) return;

    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *urlStr = [NSString stringWithFormat:@"https://keyauth.win/api/1.1/?type=login&name=%@&ownerid=%@&secret=%@&version=%@&key=%@&hwid=%@", 
                        name, ownerid, secret, version, userKey, hwid];
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (json && [json[@"success"] boolValue]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    bukaPanelAzurite();
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // Jika key salah, app ditutup (opsional, boleh tukar ke alert)
                    exit(0); 
                });
            }
        }
    }] resume];
}

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AZURITE LOGIN" 
                                       message:@"Sila masukkan license key anda" 
                                       preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"License Key";
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            validateWithKeyAuth(alert.textFields.firstObject.text);
        }]];
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window && [UIApplication sharedApplication].windows.count > 0) window = [UIApplication sharedApplication].windows[0];
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLogin();
    });
}
