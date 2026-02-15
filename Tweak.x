#import <UIKit/UIKit.h>
#import <dlfcn.h>

// Maklumat API KeyAuth (Sama seperti screenshot 4:57)
static NSString *name = @"Azuriteadmin's Application"; 
static NSString *ownerid = @"8z9qsAXGks";
static NSString *secret = @"da132c42b065d8b3e8226fdf7c899e8fcc558023cd57c06d7c4534154541c51c";
static NSString *version = @"1.0";

// Fungsi untuk panggil menu asal
void bukaPanelAzurite() {
    // Pastikan fail azurite.dylib ada dalam folder yang sama di dalam IPA
    void *handle = dlopen("azurite.dylib", RTLD_NOW);
    if (!handle) {
        NSLog(@"[Azurite] Menu asal (azurite.dylib) tidak dijumpai!");
    }
}

// Fungsi Validate KeyAuth
void validateWithKeyAuth(NSString *userKey) {
    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // Encode URL supaya simbol ' tidak menyebabkan crash
    NSString *urlRaw = [NSString stringWithFormat:@"https://keyauth.win/api/1.1/?type=login&name=%@&ownerid=%@&secret=%@&version=%@&key=%@&hwid=%@", 
                        name, ownerid, secret, version, userKey, hwid];
    
    NSString *urlEncoded = [urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlEncoded];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json[@"success"] boolValue]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    bukaPanelAzurite();
                });
            } else {
                // Key salah, tutup aplikasi
                exit(0);
            }
        }
    }] resume];
}

// Fungsi Papar Alert Login
void showLoginAlert() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AZURITE SECURITY" 
                                       message:@"Sila masukkan license key anda" 
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"License Key";
        }];
        
        UIAlertAction *login = [UIAlertAction actionWithTitle:@"LOGIN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *key = alert.textFields.firstObject.text;
            validateWithKeyAuth(key);
        }];
        
        [alert addAction:login];
        
        // Pastikan dipaparkan pada Window utama
        UIWindow *keyWindow = nil;
        for (UIWindow *window in [UIApplication sharedApplication].windows) {
            if (window.isKeyWindow) {
                keyWindow = window;
                break;
            }
        }
        [keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

// CONSTRUCTOR: Ini yang akan jalankan menu secara automatik
%ctor {
    // Tunggu aplikasi sedia sepenuhnya (2 saat) baru tunjuk login
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLoginAlert();
    });
}
