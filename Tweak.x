#import <UIKit/UIKit.h>
#import <dlfcn.h>

static NSString *name = @"AzuriteAdmin"; // TUKAR DI DASHBOARD JUGA JADI INI
static NSString *ownerid = @"8z9qsAXGks";
static NSString *secret = @"da132c42b065d8b3e8226fdf7c899e8fcc558023cd57c06d7c4534154541c51c";
static NSString *version = @"1.0";

void bukaPanelAzurite() {
    // Kita check dulu kalau fail ni ada
    void *handle = dlopen("azurite.dylib", RTLD_NOW);
    if (!handle) {
        NSLog(@"[Azurite] ERROR: Fail azurite.dylib tidak dijumpai!");
        // Kalau tak jumpa, jangan buat apa-apa supaya tak crash
        return; 
    }
    NSLog(@"[Azurite] Menu Berjaya Dimuatkan!");
}

void validateWithKeyAuth(NSString *userKey) {
    if (!userKey || [userKey length] == 0) return;

    NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    // Gunakan stringByAddingPercentEncoding untuk elakkan crash URL
    NSString *urlRaw = [NSString stringWithFormat:@"https://keyauth.win/api/1.1/?type=login&name=%@&ownerid=%@&secret=%@&version=%@&key=%@&hwid=%@", 
                        name, ownerid, secret, version, userKey, hwid];
    
    NSString *urlEncoded = [urlRaw stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlEncoded];

    if (!url) return;

    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data && !error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (json && [json[@"success"] boolValue]) {
                // Key betul!
                dispatch_async(dispatch_get_main_queue(), ^{
                    bukaPanelAzurite();
                });
            } else {
                // Key salah, tutup app
                exit(0);
            }
        }
    }] resume];
}
