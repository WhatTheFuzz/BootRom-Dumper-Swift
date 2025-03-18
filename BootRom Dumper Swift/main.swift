//
//  main.swift
//  BootRom Dumper Swift
//
//  Created by Sean Deaton on 3/12/25.
//

import os
import Foundation
import IOKit
import IOKit.usb
import BootRomDumperFramework

private let log = Logger()

/* Check if a device is connected. */
func getiPhoneDevice() -> io_object_t {
    var matchingDict: CFMutableDictionary?
    matchingDict = IOServiceMatching(kIOUSBDeviceClassName)
    if (matchingDict == nil) {
        log.error("Couldn't create matching dictionary: \(String(describing: matchingDict))")
        return IO_OBJECT_NULL
    }
    
    var iter: io_iterator_t = 0
    let kr: kern_return_t = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict!, &iter)
    
    if (kr != kIOReturnSuccess) {
        log.error("Couldn't iterate over matching services: \(kr)")
        return IO_OBJECT_NULL
    }
    while case let device = IOIteratorNext(iter), device != IO_OBJECT_NULL {
        if device.isIPhone() || device.isInRecoveryMode() || device.isInDFUMode() {
            return device
        }
        log.info("Found device with productID \(String(describing: device.productID())), skipping...")
        IOObjectRelease(device)
        continue
    }
    return IO_OBJECT_NULL
}


func main() -> Int32 {
    /* Get the iPhone, if one exists. */
    let device = getiPhoneDevice()
    if device != IO_OBJECT_NULL {
        log.info("[+] Found iPhone")
    } else {
        log.info("[-] No iPhone found.")
        return EXIT_FAILURE
    }
    /* Get the productID (this is the model number). */
    guard let productID = device.productID() else {
        log.error("[-] Error getting the device productID.")
        return EXIT_FAILURE
    }
    log.info("[+] Product ID: \(String(format: "0x%04X", productID.intValue))")
    /* Convert the model number to a model string (iPhone1,2, etc.). */
    guard let model = productIDToModel[Int(truncating: productID)] else {
        log.error("Unknown device model number.")
        return EXIT_FAILURE
    }
    /* Convert the model number to the actual product name (iPhone 3G, etc). */
    if let productName = modelToProductName[model] {
        log.info("[+] Product name: \(productName) (\(model))")
    } else {
        log.info("[*] Unknown product name for model number: \(model).")
    }
    
    if !device.isInDFUMode() {
        log.error("[-] Device is not in DFU mode, exiting.")
        return EXIT_FAILURE
    }
    log.info("[+] Found device in DFU mode, continuing...")
    
    return EXIT_SUCCESS
}

main()
