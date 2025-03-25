//
//  kIOUSB.swift
//  BootRom Dumper Swift
//
//  Created by Sean Deaton on 3/19/25.
//

// https://gist.github.com/zachbadgett/471d72e83fee413d0f38
public let kIOUSBDeviceUserClientTypeID:   CFUUID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
    0x9d, 0xc7, 0xb7, 0x80, 0x9e, 0xc0, 0x11, 0xD4,
    0xa5, 0x4f, 0x00, 0x0a, 0x27, 0x05, 0x28, 0x61)

public let kIOCFPlugInInterfaceID:         CFUUID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
    0xC2, 0x44, 0xE8, 0x58, 0x10, 0x9C, 0x11, 0xD4,
    0x91, 0xD4, 0x00, 0x50, 0xE4, 0xC6, 0x42, 0x6F)

public let kIOUSBDeviceInterfaceID:        CFUUID = CFUUIDGetConstantUUIDWithBytes(kCFAllocatorDefault,
    0x5c, 0x81, 0x87, 0xd0, 0x9e, 0xf3, 0x11, 0xD4,
    0x8b, 0x45, 0x00, 0x0a, 0x27, 0x05, 0x28, 0x61)
