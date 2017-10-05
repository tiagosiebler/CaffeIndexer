/* * Objective-C Augments - A small, miscellaneous set of Objective-C String and Data
 * augmentations
 * Copyright (C) 2011- nicerobot
 *
 * This file is part of Objective-C Augments.
 *
 * Objective-C Augments is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Objective-C Augments is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Objective-C Augments.  If not, see <http://www.gnu.org/licenses/>.
 */


#import <CommonCrypto/CommonHMAC.h>
#import "BaseCharacters.h"
#import "lcm.h"
#import "NSData+stringAsBase.h"
#import "NSString+stringAsReverseString.h"

@implementation NSData (stringAsBase)

-(NSString*) stringAsBase:(int) base {
  return [self stringAsBase:base withPadding:true];
}

-(NSString*) stringAsBase:(int) base withPadding:(BOOL) pad {

  // baseN
  NSString *bases = [BaseCharacters get:base];
  if (!bases) return nil;

  unsigned char length = [bases length] - 1;

  unsigned char bits = 0;
  unsigned int maximum = 1;
  for(int i=length; i!=0; i>>=1) {
    ++bits;
    maximum <<= 0x1;
  }

  unsigned char overflow = 0;
  // If the base isn't a power of 2, use the last character of the base as an
  // overflow indicator.
  if (0 != (maximum ^ (length+1))) {
    overflow = [bases characterAtIndex:length--];
  }

  // Bytes required for padding.
  unsigned char bytes_required = lcm(bits,8)/8;
  // mask bits
  unsigned int mask_bits = maximum -1;
  
  // Length of the data being converted.
 uint64_t data_length = [self length];
  
  unsigned int total_bits = data_length * 8;
  unsigned char padding = total_bits % bits % bytes_required;
  
  unsigned char remainder = 0;
  unsigned int data_index = 0;

  unsigned char shifter_size = sizeof(unsigned short);
  unsigned int shifter_bits = shifter_size*8-8;
  unsigned short shifter = 0;
  unsigned int shifted = 0;
  
  unsigned char *data = (unsigned char*) [self bytes];
  // Seed the shifter.
  for (int i=0; i<shifter_size; i++) {
    shifter <<= 8;
    if (data_index<data_length) {
      shifter |= data[data_index++];
    }
  }
  
  // Clear the results.
  // The maximum length is one character per bit.
  unsigned int result_index = data_length*8+padding+1;
  // NSString+Bases depends on this being an NSMutableString.
  NSMutableString *result = [NSMutableString stringWithCapacity:result_index];
  
  /*
   printf("\nbase %d - mask:%02x - bits:%d - total:%d - max:%02x - pad:%d - size:%d - shift:%d - %04X\n",
   length, mask_bits, bits, total_bits, maximum, padding, shifter_size, shifter_bits, shifter); //*/
  
  do {
    //printf("%03d %02x\n",data_index,data[data_index]);
    // Mask-off the left-most 'bits' from shifter
    // and use it as the index into the base's digits array.
    unsigned char leftmost_bits = mask_bits & ( shifter >> (shifter_bits+8-bits) );
    @try {
      if (leftmost_bits > length) {
        [result appendFormat:@"%c%c",overflow,[bases characterAtIndex:(leftmost_bits - length)]];
        leftmost_bits >>= 0x1;
      }
      [result appendFormat:@"%c",[bases characterAtIndex:leftmost_bits]];
    }
    @catch (NSException *exception) {
      NSLog(@"main: Caught %@: %@\n\tleftmost: %d",
            [exception name], [exception reason],
            leftmost_bits);
      break;
    }
    
    // Remove the left-most 'bits'.
    // If there's a remainder and bits > remainder,
    // shift-left remainder, append next_byte, shift different
    if (0 != remainder && remainder < bits) {
      shifter <<= remainder;
      if (data_index < data_length) {
        shifter |= data[data_index++];
      }
      shifter <<= bits-remainder;
    } else {
      shifter <<= bits;
    }
    
    shifted += bits;
    remainder = 8-shifted%8;
    
    // If shifted to a byte boundary, pull the next byte.
    if (8 == remainder && data_index < data_length) {
      shifter |= data[data_index++];
    }
    
    // Do this while shifter has been shifted fewer than 8 bits.        
  } while (shifted < total_bits);
  
  while(pad && padding) {
    [result appendFormat:@"="];
    --padding;
  }

  return result;
}

-(NSString*) stringAsBase2 { return [self stringAsBase:2]; }
-(NSString*) stringAsBase8 { return [self stringAsBase:8]; }
-(NSString*) stringAsBase16 { return [self stringAsBase:16]; }
-(NSString*) stringAsBase32 { return [self stringAsBase:32]; }
-(NSString*) stringAsBase64 { return [self stringAsBase:64]; }
-(NSString*) stringAsBase94 { return [self stringAsBase:94]; }

-(NSString*) stringAsBase2withPadding:(BOOL) pad { return [self stringAsBase:2 withPadding:pad]; }
-(NSString*) stringAsBase8withPadding:(BOOL) pad { return [self stringAsBase:8 withPadding:pad]; }
-(NSString*) stringAsBase16withPadding:(BOOL) pad { return [self stringAsBase:16 withPadding:pad]; }
-(NSString*) stringAsBase32withPadding:(BOOL) pad { return [self stringAsBase:32 withPadding:pad]; }
-(NSString*) stringAsBase64withPadding:(BOOL) pad { return [self stringAsBase:64 withPadding:pad]; }
-(NSString*) stringAsBase94withPadding:(BOOL) pad { return [self stringAsBase:94 withPadding:pad]; }

@end
