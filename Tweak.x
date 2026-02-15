#import <UIKit/UIKit.h>

// Maklumat API KeyAuth
static NSString *name = @"azuriteadmin"; 
static NSString *ownerid = @"8z9qsAXGks";
static NSString *secret = @"fea6acbf1b1ef751775c6e12882d8dc1ffb5f264707b7428375e37ed11186697";

void validateWithKeyAuth(NSString *userKey) {
    if (!userKey || userKey.length == 0) exit(0); // Salah/Kosong terus FC

    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *urlStr = [NSString stringWithFormat:@"https://keyauth.win/api/1.1/?type=login&name=%@&ownerid=%@&secret=%@&version=1.0&key=%@&hwid=%@", 
                        name, ownerid, secret, userKey, hwid];
    
    NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (json && [json[@"success"] boolValue]) {
                // JIKA BETUL: Biarkan saja, jangan panggil apa-apa. 
                // Alert akan hilang dan user boleh main game.
                NSLog(@"[Azurite] Key Betul. Selamat bermain!");
            } else {
                // JIKA SALAH: Terus FC
                exit(0);
            }
        } else {
            // Tiada internet/Error server: FC untuk keselamatan
            exit(0);
        }
    }] resume];
}

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Cari window untuk paparkan Alert
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window && [UIApplication sharedApplication].windows.count > 0) 
            window = [UIApplication sharedApplication].windows[0];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AZURITE LOGIN" 
                                       message:@"Sila masukkan license key anda" 
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"License Key";
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            validateWithKeyAuth(alert.textFields.firstObject.text);
        }]];
        
        // Elakkan user tekan luar alert untuk tutup (Optional)
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

%ctor {
    // Tunggu 3 saat supaya game load dulu, baru minta key
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLogin();
    });
}
