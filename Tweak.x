#import <UIKit/UIKit.h>
#include <dlfcn.h>

// Fungsi buka panel asal
void bukaPanelAzurite() {
    void *handle = dlopen("azurite.dylib", RTLD_NOW);
    if (!handle) {
        NSLog(@"[Azurite] Error: azurite.dylib tidak dijumpai!");
    }
}

// Fungsi Validate KeyAuth
void validateWithKeyAuth(NSString *userKey) {
    NSString *name = @"Azuriteadmin's Application";
    NSString *ownerid = @"8z9qsAXGks";
    NSString *secret = @"da132c42b065d8b3e8226fdf7c899e8fcc558023cd57c06d7c4534154541c51c";
    NSString *version = @"1.0";
    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSString *urlRaw = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=license&key=%@&name=%@&ownerid=%@&secret=%@&version=%@&hwid=%@", 
                        userKey, name, ownerid, secret, version, hwid];
    
    NSString *urlEncoded = [urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlEncoded];

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!error && data) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json[@"success"] boolValue]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    bukaPanelAzurite();
                });
                return;
            }
        }
        
        // Jika gagal
        dispatch_async(dispatch_get_main_queue(), ^{
            exit(0);
        });
    }] resume];
}

// Paparkan Login UI
static void showLogin() {
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (!root) {
        // Jika root belum sedia, cuba lagi sekejap lagi
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            showLogin();
        });
        return;
    }

    UIAlertController *loginUI = [UIAlertController alertControllerWithTitle:@"AZURITE SECURITY" 
                                 message:@"Sila masukkan license key anda" 
                                 preferredStyle:UIAlertControllerStyleAlert];

    [loginUI addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"License Key";
    }];

    UIAlertAction *loginBtn = [UIAlertAction actionWithTitle:@"LOGIN" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = loginUI.textFields.firstObject.text;
        validateWithKeyAuth(input);
    }];

    [loginUI addAction:loginBtn];
    [root presentViewController:loginUI animated:YES completion:nil];
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLogin();
    });
}
