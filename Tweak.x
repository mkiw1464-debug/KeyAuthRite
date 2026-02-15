#import <UIKit/UIKit.h>

static NSString *name = @"azuriteadmin"; 
static NSString *ownerid = @"8z9qsAXGks";
static NSString *secret = @"fea6acbf1b1ef751775c6e12882d8dc1ffb5f264707b7428375e37ed11186697";

// Fungsi untuk tutup app dengan cara yang sah (bukan crash)
void tutupAppSelamat() {
    dispatch_async(dispatch_get_main_queue(), ^{
        // Beritahu sistem app ditutup secara sengaja
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] performSelector:@selector(terminateWithSuccess)];
        #pragma clang diagnostic pop
        
        // Backup jika selector di atas gagal
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            exit(0);
        });
    });
}

void validateWithKeyAuth(NSString *userKey) {
    if (!userKey || userKey.length == 0) {
        tutupAppSelamat();
        return;
    }

    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *urlRaw = [NSString stringWithFormat:@"https://keyauth.win/api/1.1/?type=login&name=%@&ownerid=%@&secret=%@&version=1.0&key=%@&hwid=%@", name, ownerid, secret, userKey, hwid];
    
    NSURL *url = [NSURL URLWithString:[urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    // Gunakan Default Session untuk kestabilan maksimum pada IPA yang di-sideload
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // WAJIB: Masuk ke Main Thread sebelum buat apa-apa tindakan
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data && !error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (json && [json[@"success"] boolValue]) {
                    // BERJAYA: Biarkan user main. Kotak alert akan hilang sendiri.
                    NSLog(@"[Azurite] Key Validated!");
                } else {
                    // SALAH: Tutup app dengan selamat
                    tutupAppSelamat();
                }
            } else {
                // MASALAH INTERNET: Tutup app
                tutupAppSelamat();
            }
        });
    }] resume];
}

void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window && [UIApplication sharedApplication].windows.count > 0) {
            window = [UIApplication sharedApplication].windows[0];
        }

        if (!window || !window.rootViewController) return;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AZURITE LOGIN" 
                                       message:@"Sila masukkan license key anda" 
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"License Key";
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            validateWithKeyAuth(alert.textFields.firstObject.text);
        }]];
        
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

%ctor {
    // Tunggu 5 saat supaya game betul-betul habis load UI asal dia
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLogin();
    });
}
