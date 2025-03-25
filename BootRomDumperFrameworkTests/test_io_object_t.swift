//
//  test_io_object_t.swift
//  BootRom Dumper Swift
//
//  Created by Sean Deaton on 3/12/25.
//

import IOKit
import IOKit.usb
import IOKit.usb.IOUSBLib

import Testing
@testable import BootRomDumperFramework

/**
 Tests the extensions added to `io_object_t`.
 */
struct test_io_object_t {
    
    var device: io_object_t = IO_OBJECT_NULL
    
    init () async throws {
        var matchingDict: CFMutableDictionary?
        matchingDict = IOServiceMatching(kIOUSBDeviceClassName)
        #expect(matchingDict != nil, "IOServiceMatching failed")
        
        var iter: io_iterator_t = 0
        let kr: kern_return_t = IOServiceGetMatchingServices(kIOMainPortDefault, matchingDict!, &iter)
        #expect(kr == kIOReturnSuccess, "IOServiceGetMatchingServices failed")
        
        self.device = IOIteratorNext(iter)
        #expect(device != IO_OBJECT_NULL, "IOIteratorNext failed")
        if device == IO_OBJECT_NULL {
            fatalError( "Failed to find a valid device. Is there a USB device plugged in?")
        }
    }
    
    @Test("Verify a valid name is returned.")
    func name() {
        #expect(self.device != IO_OBJECT_NULL, "No device found to get the name of.")
        #expect(self.device.name() != nil, "Failed to get the name of the device.")
    }
    
    @Test("Verify a valid path is found.")
    func path() {
        #expect(self.device != IO_OBJECT_NULL, "No device found to get the path of.")
        #expect(self.device.path() != nil, "Failed to get the path of the device.")
    }
    
    @Test("Verify we get a productID.")
    func productID() {
        #expect(self.device != IO_OBJECT_NULL, "No device found to get the productID of.")
        #expect(self.device.productID() != 0, "Failed to get the product ID of the device.")
    }
    
    @Test("Get the plugin interface.")
    func pluginInterface() {
        #expect(self.device != IO_OBJECT_NULL, "No device found to get the plugin interface of.")
        #expect(self.device.pluginInterface() != nil, "Failed to get the plugin interface of the device.")
    }
    
    @Test("Get the device interface from the plugin.")
    func deviceInterface() {
        #expect(self.device != IO_OBJECT_NULL, "No device found to get the device interface from the plugin of.")
        #expect(self.device.deviceInterface() != nil, "Failed to get the device interface from the plugin of the device.")
    }
}
