/* AFC2 - the original definition of "jailbreak"
 * Copyright (C) 2014  Jay Freeman (saurik)
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

#include <Foundation/Foundation.h>
#include <CommonCrypto/CommonDigest.h>
#include <zlib.h>

#define _failif(test) \
    if (test) return @ #test;

static NSString *download() {
    // iPhone3,1 runs armv7: not that it matters, but we don't have an arm64 full update; and as iOS 7 does not support armv6, this one URL covers all users ;P
    NSString *url(@"http://appldnld.apple.com/iOS7/091-9438.20130918.Lkki8/com_apple_MobileAsset_SoftwareUpdate/7725c7df3d8b6617915ad0d80789fbf4d2b18823.zip");

    NSMutableURLRequest *request([NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]]);
    [request setHTTPShouldHandleCookies:NO];
    [request setValue:@"bytes=1053518009-1053526335" forHTTPHeaderField:@"Range"];
    printf("downloading afcd...\n");

    NSHTTPURLResponse *response(nil);

    NSError *error(nil);
    NSData *data([NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error]);
    if (error != nil) return [error localizedDescription];

    _failif(response == nil);
    _failif([response statusCode] != 206);

    _failif(data == nil);
    _failif([data length] != 0x2087);

    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([data bytes], [data length], digest);
    _failif(memcmp(digest, (uint8_t[]) {0x7c,0x20,0x8c,0xa7,0x7a,0x2b,0xcb,0x04,0xa9,0x61,0x9b,0x73,0x70,0x5d,0xb3,0x3f,0x36,0x2b,0x1e,0xa5}, sizeof(digest)) != 0);

    z_stream stream;
    memset(&stream, 0, sizeof(stream));

    stream.next_in = static_cast<Bytef *>(const_cast<void *>([data bytes]));
    stream.avail_in = [data length];

    char buffer[0x5fb0];
    stream.next_out = reinterpret_cast<Bytef *>(buffer);
    stream.avail_out = sizeof(buffer);

    _failif(inflateInit2(&stream, -15) != Z_OK);
    _failif(inflate(&stream, Z_SYNC_FLUSH) != Z_STREAM_END);
    _failif(inflateEnd(&stream) != Z_OK);

    _failif(stream.avail_in != 0);
    _failif(stream.avail_out != 0);

    bool written([[NSData dataWithBytes:buffer length:sizeof(buffer)] writeToFile:@"/usr/libexec/afc2d" atomically:YES]);
    _failif(!written);
    return nil;
}

int main(int argc, const char *argv[]) {
    if (argc < 2 || (
        strcmp(argv[1], "install") != 0 &&
        strcmp(argv[1], "upgrade") != 0 &&
    true)) return 0;

    NSAutoreleasePool *pool([[NSAutoreleasePool alloc] init]);

    if (kCFCoreFoundationVersionNumber >= 800)
        if (NSString *error = download()) {
            fprintf(stderr, "error: %s\n", [error UTF8String]);
            return 1;
        }

    if (kCFCoreFoundationVersionNumber < 1000) {
        NSString *path(@"/System/Library/Lockdown/Services.plist");

        NSMutableDictionary *services([NSMutableDictionary dictionaryWithContentsOfFile:path]);
        if (services == nil) {
            fprintf(stderr, "cannot read Services.plist\n");
            return 1;
        }

        [services setObject:@{
            @"AllowUnactivatedService": @true,
            @"Label": @"com.apple.afc2",
            @"ProgramArguments": @[@"/usr/libexec/afc2d", @"-S", @"-L", @"-d", @"/"],
        } forKey:@"com.apple.afc2"];

        if (![services writeToFile:path atomically:YES]) {
            fprintf(stderr, "cannot write Services.plist\n");
            return 1;
        }
    }

    system("/bin/launchctl stop com.apple.mobile.lockdown");

    [pool release];
    return 0;
}
