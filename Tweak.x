#import <UIKit/UIKit.h>

static NSString *name = @"azuriteadmin"; 
static NSString *ownerid = @"8z9qsAXGks";
static NSString *secret = @"fea6acbf1b1ef751775c6e12882d8dc1ffb5f264707b7428375e37ed11186697";

// Fungsi untuk tutup app (FC) dengan selamat
void forceCloseApp() {
    dispatch_async(dispatch_get_main_queue(), ^{
        exit(0);
    });
}

void validateWithKeyAuth(NSString *userKey) {
    if (!userKey || userKey.length == 0) {
        forceCloseApp();
        return;
    }

    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *urlRaw = [NSString stringWithFormat:@"https://keyauth.win/api/1.1/?type=login&name=%@&ownerid=%@&secret=%@&version=1.0&key=%@&hwid=%@", 
                        name, ownerid, secret, userKey, hwid];
    
    NSURL *url = [NSURL URLWithString:[urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            // Masuk ke Main Thread sebelum buat apa-apa keputusan
            dispatch_async(dispatch_get_main_queue(), ^{
                if (json && [json[@"success"] boolValue]) {
                    NSLog(@"[Azurite] Login Berjaya!");
                    // Alert akan tertutup sendiri, user boleh main.
                } else {
                    forceCloseApp();
                }
            });
        } else {
            forceCloseApp();
        }
    }] resume];
}

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Cara paling selamat cari window di iOS moden
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
        
        // Elakkan crash jika rootViewController tak sedia
        UIViewController *rootVC = window.rootViewController;
        if (rootVC) {
            [rootVC presentViewController:alert animated:YES completion:nil];
        }
    });
}

%ctor {
    // Tambah masa delay kepada 5 saat supaya game betul-betul habis loading
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLogin();
    });
}
