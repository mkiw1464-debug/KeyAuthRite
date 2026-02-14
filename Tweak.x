#import <UIKit/UIKit.h>
#include <dlfcn.h>

// =======================================================
// FUNGSI LOAD PANEL ASAL (AZURITE)
// =======================================================
void bukaPanelAzurite() {
    // Pastikan azurite.dylib ada dalam folder yang sama masa inject
    void *handle = dlopen("azurite.dylib", RTLD_NOW);
    if (!handle) {
        NSLog(@"[Azurite] Error: azurite.dylib tidak dijumpai!");
    }
}

// =======================================================
// FUNGSI VALIDATE KEYAUTH (1D, 3D, 7D, 31D + HWID LOCK)
// =======================================================
void validateWithKeyAuth(NSString *userKey) {
    // INFO KEYAUTH KAMU
    NSString *name = @"Azuriteadmin's Application";
    NSString *ownerid = @"8z9qsAXGks";
    NSString *secret = @"da132c42b065d8b3e8226fdf7c899e8fcc558023cd57c06d7c4534154541c51c";
    NSString *version = @"1.0";
    
    // Ambil ID peranti untuk HWID Lock
    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // Bina URL API
    NSString *urlRaw = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=license&key=%@&name=%@&ownerid=%@&secret=%@&version=%@&hwid=%@", 
                        userKey, name, ownerid, secret, version, hwid];
    
    // Encode URL supaya simbol ' dan ruang kosong tidak error
    NSString *urlEncoded = [urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlEncoded];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) {
            NSLog(@"[Azurite] Tiada sambungan internet.");
            return;
        }

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        // Semak jika "success" adalah true dari KeyAuth
        if ([json[@"success"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // LOGIN BERJAYA - Buka menu utama
                bukaPanelAzurite();
            });
        } else {
            // LOGIN GAGAL (Expired / Salah Key / HWID Lock)
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *msg = json[@"message"] ?: @"Kunci Tidak Sah!";
                
                UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"AZURITE SECURITY" 
                                                message:msg 
                                                preferredStyle:UIAlertControllerStyleAlert];
                
                [errorAlert addAction:[UIAlertAction actionWithTitle:@"Keluar Game" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    exit(0); 
                }]];
                
                [[UIApplication sharedSession].keyWindow.rootViewController presentViewController:errorAlert animated:YES completion:nil];
            });
        }
    }] resume];
}

// =======================================================
// CONSTRUCTOR (MUNCULKAN POPUP LOGIN MASA START)
// =======================================================
%ctor {
    // Tunggu 5 saat selepas game dibuka baru muncul popup
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIAlertController *loginUI = [UIAlertController alertControllerWithTitle:@"AZURITE EXTERNAL" 
                                     message:@"Sila masukkan key anda\n(1d / 3d / 7d / 31d)" 
                                     preferredStyle:UIAlertControllerStyleAlert];

        [loginUI addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Masukkan License Key";
            textField.textAlignment = NSTextAlignmentCenter;
        }];

        UIAlertAction *loginBtn = [UIAlertAction actionWithTitle:@"LOGIN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *input = loginUI.textFields.firstObject.text;
            if (input.length > 3) {
                validateWithKeyAuth(input);
            } else {
                exit(0);
            }
        }];

        [loginUI addAction:loginBtn];
        
        // Paparkan ke skrin
        [[UIApplication sharedSession].keyWindow.rootViewController presentViewController:loginUI animated:YES completion:nil];
    });
}
