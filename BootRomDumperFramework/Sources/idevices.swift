//
//  idevices.swift
//  BootRom Dumper Swift
//
//  Created by Sean Deaton on 3/14/25.
//

/**
 - Note: See reference of USB Product IDs from the [Apple Wiki](https://theapplewiki.com/wiki/USB_Product_IDs).
 */
public let DFUProductIDs: [Int] = [0x1220, 0x1221, 0x1222, 0x1223, 0x1225, 0x1227, 0x1231, 0x1232, 0x1234]

/**
 - Note: See reference of USB Product IDs from the [Apple Wiki](https://theapplewiki.com/wiki/USB_Product_IDs).
 */
public let RecoveryProductIDs: [Int] = [0x1280, 0x1281]

/**
 - Note: See reference of USB Product IDs from the [Apple Wiki](https://theapplewiki.com/wiki/USB_Product_IDs).
 */
public let IPhoneProductIDs: [Int] = [0x1290, 0x1292]

/**
 - Note: See reference of USB Product IDs from the [Apple Wiki](https://theapplewiki.com/wiki/USB_Product_IDs).
 */
public let productIDToModel: Dictionary<Int, String> = [
    0x1222: "iPhone1,1, iPhone 1,2, and iPod1,1 (DFU Mode)",
    0x1227: "iPhone1,2 (DFU Mode)",
    0x1280: "Unknown (Recovery Mode)",
    0x1281: "iPhone1,1 (Recovery Mode)",
    0x1290: "iPhone1,1",
    0x1291: "iPod1,1",
    0x1292: "iPhone1,2",
    0x1293: "iPod2,1",
    0x1294: "iPhone2,1",
    0x1295: "iPod3,1",
    0x1296: "iPhone3,1",
    0x1297: "iPhone3,2",
    0x1298: "iPhone3,3",
    0x1299: "iPod4,1",
]

public let modelToProductName: Dictionary<String, String> = [
    "iPhone1,1, iPhone 1,2, and iPod1,1 (DFU Mode)": "iPhone 2G, iPhone 3G and iPod Touch 1G (DFU Mode)",
    "Unknown (Recovery Mode)": "Unknown (Recovery Mode)",
    "iPhone1,1 (Recovery Mode)": "iPhone 1G (Recovery Mode)",
    "iPhone1,1": "iPhone 2G",
    "iPod1,1": "iPod Touch 1G",
    "iPhone1,2": "iPhone 3G",
    "iPod2,1": "iPod Touch 2G",
    "iPhone2,1": "iPhone 3GS",
    "iPod3,1": "iPod Touch 3G",
]
