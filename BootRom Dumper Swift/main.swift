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
        
        guard let productID = device.productID() else {
            log.error("Couldn't get productID of device, skipping...")
            continue
        }
        log.debug("[*] Found device with productID \(productID).")

        let name: String? = device.name()
        
        if name == "iPhone" || name == "Apple Mobile Device (Recovery Mode)" {
            return device
        }
        // Otherwise, release the device and check the next ones.
        log.debug("[*] Found \(String(describing: name)), skipping...")
        IOObjectRelease(device);
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
    guard let productName = modelToProductName[model] else {
        log.error("Unknown product name for model number: \(model).")
        return EXIT_FAILURE
    }
    log.info("[+] Product name: \(productName) (\(model))")
    
    
    return EXIT_SUCCESS
}

main()
