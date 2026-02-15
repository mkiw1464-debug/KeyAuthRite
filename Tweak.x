#import <UIKit/UIKit.h>
#import <dlfcn.h>

// Gunakan nama ringkas di Dashboard & Kod (Contoh: AzuriteAdmin)
static NSString *name = @"AzuriteAdmin"; 
static NSString *ownerid = @"8z9qsAXGks";
static NSString *secret = @"da132c42b065d8b3e8226fdf7c899e8fcc558023cd57c06d7c4534154541c51c";
static NSString *version = @"1.0";

void bukaPanelAzurite() {
    // Gunakan NULL handle untuk check dylib dalam bundle
    void *handle = dlopen("azurite.dylib", RTLD_NOW);
    if (!handle) {
        NSLog(@"[Azurite] Fail menu tidak dijumpai: %s", dlerror());
        return;
    }
    NSLog(@"[Azurite] Menu Berjaya Dibuka!");
}

// Fungsi Validate yang lebih stabil (Handle symbols & spaces)
void validateWithKeyAuth(NSString *userKey) {
    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // Gunakan URL yang bersih
    NSString *urlRaw = [NSString stringWithFormat:@"https://keyauth.win/api/1.1/?type=login&name=%@&ownerid=%@&secret=%@&version=%@&key=%@&hwid=%@", 
                        name, ownerid, secret, version, userKey, hwid];
    
    // Penting: Encode URL supaya simbol ' atau ruang tidak menyebabkan crash
    NSString *urlEncoded = [urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlEncoded];
    
    if (!url) return;

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json[@"success"] boolValue]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    bukaPanelAzurite();
                });
            } else {
                // Key salah atau expired - Tutup Game
                exit(0);
            }
        }
    }] resume];
}
