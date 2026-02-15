#import <UIKit/UIKit.h>
#import <dlfcn.h>

static NSString *name = @"Azuriteadmin's Application"; 
static NSString *ownerid = @"8z9qsAXGks";
static NSString *secret = @"da132c42b065d8b3e8226fdf7c899e8fcc558023cd57c06d7c4534154541c51c";

void bukaPanelAzurite() {
    // 1. Cuba cari dylib dalam folder Documents (tempat biasa injection)
    NSString *path = [[NSBundle mainBundle] pathForResource:@"azurite" ofType:@"dylib"];
    if (!path) {
        path = @"azurite.dylib"; // Fallback ke root
    }

    void *handle = dlopen([path UTF8String], RTLD_NOW);
    
    if (!handle) {
        // JANGAN BIARKAN CRASH. Paparkan mesej ralat jika fail tiada.
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"MENU TIDAK JUMPA" 
                                           message:@"Sila extract .deb dan pastikan fail dinamakan azurite.dylib" 
                                           preferredStyle:UIAlertControllerStyleAlert];
            [errorAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:errorAlert animated:YES completion:nil];
        });
        return;
    }
}

void validateWithKeyAuth(NSString *userKey) {
    // ... (Kod validation kamu yang sedia ada) ...
    // Pastikan di dalam completion handler, panggil bukaPanelAzurite();
}

// ... (Fungsi showLoginAlert) ...

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showLoginAlert();
    });
}
