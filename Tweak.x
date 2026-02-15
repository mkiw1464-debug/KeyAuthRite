#import <UIKit/UIKit.h>

static NSString *name = @"azuriteadmin"; 
static NSString *ownerid = @"8z9qsAXGks";
static NSString *secret = @"fea6acbf1b1ef751775c6e12882d8dc1ffb5f264707b7428375e37ed11186697";

// Fungsi login
void checkKey(NSString *userKey) {
    if (!userKey || userKey.length == 0) {
        exit(0);
        return;
    }

    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    // Gunakan HTTPS yang lebih ringkas
    NSString *urlRaw = [NSString stringWithFormat:@"https://keyauth.win/api/1.1/?type=login&name=%@&ownerid=%@&secret=%@&version=1.0&key=%@&hwid=%@", name, ownerid, secret, userKey, hwid];
    NSString *urlEncoded = [urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlEncoded] timeoutInterval:10.0];

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (json && [json[@"success"] boolValue]) {
                // KEY BETUL: Biarkan user main. Log untuk debug.
                NSLog(@"[Azurite] Login Success");
            } else {
                // KEY SALAH: Tutup app
                dispatch_async(dispatch_get_main_queue(), ^{ exit(0); });
            }
        } else {
            // ERROR INTERNET: Tutup app
            dispatch_async(dispatch_get_main_queue(), ^{ exit(0); });
        }
    }] resume];
}

// Papar Alert dengan cara yang takkan FC
void showLoginAlert() {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Cari ViewController yang paling atas (Top Most)
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }

        if (!topController) return;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AZURITE SECURITY" 
                                       message:@"Sila masukkan license key anda" 
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"License Key";
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"LOGIN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *key = alert.textFields.firstObject.text;
            checkKey(key);
        }]];
        
        [topController presentViewController:alert animated:YES completion:nil];
    });
}

%ctor {
    // Gunakan notifikasi sistem supaya dia panggil Alert hanya bila App dah betul-betul sedia
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification 
                                                      object:nil 
                                                       queue:[NSOperationQueue mainQueue] 
                                                  usingBlock:^(NSNotification *note) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            showLoginAlert();
        });
    }];
}
