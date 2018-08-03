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

#include <CoreFoundation/CoreFoundation.h>
#include <Foundation/Foundation.h>

%hookf(CFPropertyListRef, CFPropertyListCreateWithData, CFAllocatorRef allocator, CFDataRef data, CFOptionFlags options, CFPropertyListFormat *format, CFErrorRef *error) {
    CFPropertyListRef list(%orig(allocator, data, options, format, error));
    NSDictionary *dict((NSDictionary *) list);

    if ([dict objectForKey:@"com.apple.afc"] != nil) {
        NSMutableDictionary *copy([dict mutableCopy]);
        CFRelease(list);
        list = (CFPropertyListRef) copy;

        [copy setObject:@{
            @"AllowUnactivatedService": @true,
            @"Label": @"com.apple.afc2",
            @"ProgramArguments": @[@"/usr/libexec/afc2d", @"-S", @"-L", @"-d", @"/"],
        } forKey:@"com.apple.afc2"];

        NSLog(@"akemi_afc2dService: contents of copy stg2 are %@", copy);
    }

    return list;
}
