/* AFC2 - the original definition of "jailbreak"
 * Copyright (C) 2014  Jay Freeman (saurik)
 * Copyright (C) 2018  Cannathea
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

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <rootless.h>

%hookf(CFPropertyListRef, CFPropertyListCreateWithData, CFAllocatorRef allocator, CFDataRef data, CFOptionFlags options, CFPropertyListFormat *format, CFErrorRef *error)
{
    CFPropertyListRef originalPropertyList = %orig;
    NSDictionary *propertyList = (NSDictionary *)CFBridgingRelease(originalPropertyList);

    if (![propertyList isKindOfClass:[NSDictionary class]] || !propertyList[@"com.apple.afc"]) {
        return CFBridgingRetain(propertyList);
    }

    NSMutableDictionary *services = [propertyList mutableCopy];
    services[@"com.apple.afc2"] = @{
        @"AllowUnactivatedService": @true,
        @"Label": @"com.apple.afc2",
        @"ProgramArguments": @[ROOT_PATH_NS(@"/usr/libexec/afc2d"), @"-S", @"-L", @"-d", @"/"],
    };
    return CFBridgingRetain(services);
}
