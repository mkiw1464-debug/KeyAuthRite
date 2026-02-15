#import <UIKit/UIKit.h>
#import <dlfcn.h>

// Maklumat API KeyAuth - Pastikan sama dengan Dashboard
static NSString *name = @"Azuriteadmin's Application"; 
static NSString *ownerid = @"8z9qsAXGks";
static NSString *secret = @"da132c42b065d8b3e8226fdf7c899e8fcc558023cd57c06d7c4534154541c51c";
static NSString *version = @"1.0";

// Fungsi untuk panggil menu asal (Mesti guna .dylib hasil extract)
void bukaPanelAzurite() {
    // Pastikan fail azurite.dylib ada dalam folder yang sama dalam IPA
    void *handle = dlopen("azurite.dylib", RTLD_NOW);
    
    if (!handle) {
        NSLog(@"[Azurite] ERROR: Menu (azurite.dylib) tidak dijumpai: %s", dlerror());
        
        // Alert amaran jika fail hilang/salah format
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *err = [UIAlertController alertControllerWithTitle:@"System Error" 
                                     message:@"Fail azurite.dylib tidak dijumpai! Pastikan anda extract .deb dan ambil .dylib sahaja." 
                                     preferredStyle:UIAlertControllerStyleAlert];
            [err addAction:[UIAlertAction actionWithTitle:@"Faham" style:UIAlertActionStyleDefault handler:nil]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:err animated:YES completion:nil];
        });
        return;
    }
    NSLog(@"[Azurite] SUCCESS: Menu asal berjaya dimuatkan.");
}

// Fungsi Validate KeyAuth
void validateWithKeyAuth(NSString *userKey) {
    if (!userKey || [userKey length] == 0) return;

    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // Bina URL dan bersihkan (Encode) untuk elakkan crash
    NSString *urlRaw = [NSString stringWithFormat:@"https://keyauth.win/api/1.1/?type=login&name=%@&ownerid=%@&secret=%@&version=%@&key=%@&hwid=%@", 
                        name, ownerid, secret, version, userKey, hwid];
    
    NSString *urlEncoded = [urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlEncoded];

    if (!url) return;

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            if (json && [json[@"success"] boolValue]) {
                // LOGIN BERJAYA
                dispatch_async(dispatch_get_main_queue(), ^{
                    bukaPanelAzurite();
                });
            } else {
                // LOGIN GAGAL - Tutup App
                exit(0);
            }
        }
    }] resume];
}

// Fungsi Papar Alert Login
void showLoginAlert() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AZURITE SECURITY" 
                                       message:@"Masukkan License Key anda" 
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"License Key";
            textField.secureTextEntry = NO;
        }];
        
        UIAlertAction *login = [UIAlertAction actionWithTitle:@"LOGIN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *enteredKey = alert.textFields.firstObject.text;
            validateWithKeyAuth(enteredKey);
        }];
        
        [alert addAction:login];
        
        // Cari window yang aktif untuk tunjuk alert
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
                if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                    for (UIWindow *w in windowScene.windows) {
                        if (w.isKeyWindow) {
                            window = w;
                            break;
                        }
                    }
                }
            }
        } else {
            window = [UIApplication sharedApplication].keyWindow;
        }
        
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

// CONSTRUCTOR - Jalankan menu automatik bila app dibuka
%ctor {
    // Tunggu 3 saat bagi memastikan UI aplikasi sedia
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLoginAlert();
    });
}
