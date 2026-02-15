#import <UIKit/UIKit.h>
#import <string>
#include "skCrypt.h" // Pastikan fail skCrypt.h ada dalam folder projek

using namespace std;

// Fungsi Login
void validateWithKeyAuth(NSString *userKey) {
    if (!userKey || userKey.length == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{ exit(0); });
        return;
    }

    // Menggunakan skCrypt kamu untuk maklumat API
    string name = skCrypt("azuriteadmin").decrypt(); 
    string ownerid = skCrypt("8z9qsAXGks").decrypt(); 
    string secret = skCrypt("fea6acbf1b1ef751775c6e12882d8dc1ffb5f264707b7428375e37ed11186697").decrypt();
    string version = skCrypt("1.0").decrypt(); 
    string apiUrl = skCrypt("https://keyauth.win/api/1.1/").decrypt();

    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // Bina URL secara dinamik
    NSString *urlRaw = [NSString stringWithFormat:@"%s?type=login&name=%s&ownerid=%s&secret=%s&version=%s&key=%@&hwid=%@", 
                        apiUrl.c_str(), name.c_str(), ownerid.c_str(), secret.c_str(), version.c_str(), userKey, hwid];
    
    NSURL *url = [NSURL URLWithString:[urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // Balik ke Main Thread untuk elakkan FC
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data && !error) {
                NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (json && [json[@"success"] boolValue]) {
                    // BERJAYA: Simpan log dan biarkan user main
                    NSLog(@"[Azurite] Login Berjaya!");
                } else {
                    // SALAH: Tutup game (FC)
                    exit(0);
                }
            } else {
                // TIADA INTERNET / SERVER DOWN: FC
                exit(0);
            }
        });
    }] resume];
}

// Paparkan Kotak Login
void showLogin() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window && [UIApplication sharedApplication].windows.count > 0) 
            window = [UIApplication sharedApplication].windows[0];

        if (!window || !window.rootViewController) return;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"AZURITE SECURITY" 
                                       message:@"Sila masukkan license key anda" 
                                       preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"License Key";
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"LOGIN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            validateWithKeyAuth(alert.textFields.firstObject.text);
        }]];
        
        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

%ctor {
    // Delay 10 saat supaya anticheat game dah habis loading
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLogin();
    });
}
