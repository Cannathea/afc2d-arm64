/* AFC2 - the original definition of "jailbreak"
 * Copyright (C) 2014  Jay Freeman (saurik)
 * Copyright (C) 2018 - 2023 Cannathea
 */

/* GNU General Public License, Version 3 {{{ */
/*
 * Cydia is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * Cydia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Cydia.  If not, see <http://www.gnu.org/licenses/>.
 **/
/* }}} */

#import <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>
#include <zlib.h>
#import <version.h>
#import "../easy_spawn.h"
#import "../rootless.h"
#import <dlfcn.h>
#import <sys/stat.h>
#import <unistd.h>

#define LDID "/usr/bin/ldid"
#define FLAG_PATH @"/usr/libexec/afc2dSupport" // Set afc2d to download only once

#define _failif(test) \
    if (test) return @ #test;

#define FLAG_PLATFORMIZE (1 << 1)

void platformize_me() {
    void *handle = dlopen("/usr/lib/libjailbreak.dylib", RTLD_LAZY);
    if (!handle) return;
    // Reset errors
    dlerror();
    typedef void (*fix_entitle_prt_t)(pid_t pid, uint32_t what);
    fix_entitle_prt_t ptr = (fix_entitle_prt_t)dlsym(handle, "jb_oneshot_entitle_now");

    const char *dlsym_error = dlerror();
    if (dlsym_error) return;

    ptr(getpid(), FLAG_PLATFORMIZE);
}

void patch_setuid() {
    void *handle = dlopen("/usr/lib/libjailbreak.dylib", RTLD_LAZY);
    if (!handle) return;
    // Reset errors
    dlerror();
    typedef void (*fix_setuid_prt_t)(pid_t pid);
    fix_setuid_prt_t ptr = (fix_setuid_prt_t)dlsym(handle, "jb_oneshot_fix_setuid_now");

    const char *dlsym_error = dlerror();
    if (dlsym_error) return;

    ptr(getpid());
}

static NSString *download() {
    // This downloads an arm64 binary, as we're only interested in iOS 11 support here (that being said, this works on any arm64 device)
    // However, it would not be impossible to lipo together a giant afc2d binary if we wanted full compatibility across all iOS versions…
    NSString *url(@"http://appldnld.apple.com/iOS7/031-3029.20140221.ramz3/com_apple_mobileasset_softwareupdate/92b6344e610f418586f1741231ffab482e6d49fd.zip");

    NSMutableURLRequest *request([NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]]);
    [request setHTTPShouldHandleCookies:NO];
    [request setValue:@"bytes=1310657433-1310666346" forHTTPHeaderField:@"Range"];
    printf("downloading afcd...\n");

    NSHTTPURLResponse *response(nil);

    NSError *error(nil);
    NSData *data([NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error]);
    if (error != nil) return [error localizedDescription];

    _failif(response == nil);
    _failif([response statusCode] != 206);

    _failif(data == nil);
    _failif([data length] != 0x22d2);

    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([data bytes], [data length], digest);
    _failif(memcmp(digest, (uint8_t[]) {0xa6,0x86,0x0a,0x87,0x6d,0x3c,0xd0,0xa8,0xd6,0x4b,0x51,0x95,0x86,0x0c,0xdb,0xdf,0xef,0xba,0xc0,0xc5}, sizeof(digest)) != 0);

    z_stream stream;
    memset(&stream, 0, sizeof(stream));

    stream.next_in = static_cast<Bytef *>(const_cast<void *>([data bytes]));
    stream.avail_in = [data length];

    char buffer[0xa210];
    stream.next_out = reinterpret_cast<Bytef *>(buffer);
    stream.avail_out = sizeof(buffer);

    _failif(inflateInit2(&stream, -15) != Z_OK);
    _failif(inflate(&stream, Z_SYNC_FLUSH) != Z_STREAM_END);
    _failif(inflateEnd(&stream) != Z_OK);

    _failif(stream.avail_in != 0);
    _failif(stream.avail_out != 0);

    bool written([[NSData dataWithBytes:buffer length:sizeof(buffer)] writeToFile:ROOT_PATH_NS(@"/usr/libexec/afc2d") atomically:YES]);
    _failif(!written);
    return nil;
}

static void removeHostsBlock() {
    NSString *path = @"/etc/hosts";
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSString *content = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        if ([content containsString:@"appldnld"]) {
            printf("Apple server is blocked by /etc/hosts, unblocking...\n");
            easy_spawn((const char *[]){"/bin/sed", "-i", "/appldnld/d", "/etc/hosts", NULL});
            easy_spawn((const char *[]){"killall", "mDNSResponder", "discoveryd" , NULL});
        }
    }
}

int main(int argc, const char **argv) {
    @autoreleasepool {
        patch_setuid();
        platformize_me();
        setuid(0);
        if ((chdir("/")) < 0) {
            printf("ERROR: Not run as root.\n");
            exit(EXIT_FAILURE);
        }
        
        if (IS_IOS_OR_NEWER(iOS_12_0) &&
                   [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/share/jailbreak/signcert.p12"]) {
            // For unc0ver
            easy_spawn((const char *[]){"/usr/bin/killall", "-9", "lockdownd", NULL});
        }
        // Set afc2d to download only once
        if ([[NSFileManager defaultManager] removeItemAtPath:ROOT_PATH_NS(FLAG_PATH) error:nil]) {
            // Detect whether user set /etc/hosts
            removeHostsBlock();

            if (NSString *error = download()) {
                fprintf(stderr, "error: %s\n", [error UTF8String]);
                return 1;
            }

            NSString *entitlements = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>platform-application</key><true/></dict></plist>";
            if ([entitlements writeToFile:@"/tmp/entitlements_afc2d.xml" atomically:YES encoding:NSUTF8StringEncoding error:nil]) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/share/jailbreak/signcert.p12"])
                {
                    // For unc0ver
                    easy_spawn((const char *[]){ROOT_PATH_C(LDID), "-P", "-K/usr/share/jailbreak/signcert.p12", "-S/tmp/entitlements_afc2d.xml", "/usr/libexec/afc2d", NULL});
                }
                else
                {
                    // Other Jailbreak
                    easy_spawn((const char *[]){ROOT_PATH_C(LDID), "-S/tmp/entitlements_afc2d.xml", ROOT_PATH_C("/usr/libexec/afc2d"), NULL});
                }
            } else {
                fprintf(stderr, "could not grant afc2d binary proper entitlements\n");
                return 1;
            }
            // stop com.apple.mobile.lockdown
            easy_spawn((const char *[]){(access(ROOT_PATH_C("/sbin/launchctl"), X_OK) != -1) ? ROOT_PATH_C("/sbin/launchctl") : ROOT_PATH_C("/bin/launchctl"), "stop", "com.apple.mobile.lockdown", NULL});
        }
    }
    return 0;
}
