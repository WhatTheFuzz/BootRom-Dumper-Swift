//
//  io_object_t.swift
//  BootRom Dumper Swift
//
//  Created by Sean Deaton on 3/12/25.
//

import IOKit
import IOKit.usb

public extension io_object_t {
    /**
     The name of the USB device.
     
     - Note: Getting a device's name.
     \
     ` let device: io_object_t = IOIteratorNext(iter)
     ` print(device.name() ?? "Unknown")
     
     - returns: A new String? representing the name of the USB device if
     IORegistryEntryGetName returns successfully, else nil.
     
     */
    func name() -> String? {
        let buf = UnsafeMutablePointer<io_name_t>.allocate(capacity: 1)
        defer {
            buf.deallocate()
        }
        return buf.withMemoryRebound(to: CChar.self, capacity: MemoryLayout<io_name_t>.size) {
            if IORegistryEntryGetName(self, $0) == KERN_SUCCESS {
                return String(cString: $0)
            }
            return nil
        }
    }
    
    /**
     A USB device's path.
     
     - Note: Getting the device's path.
     \
     ` let device: io_object_t = IOIteratorNext(iter)
     ` print(device.path() ?? "Unknown path")
     
     - returns: A String? with the path of the USB device.
     */
    func path() -> String? {
        let path = UnsafeMutablePointer<io_string_t>.allocate(capacity: 1)
        defer { path.deallocate() }
        return path.withMemoryRebound(to: CChar.self, capacity: MemoryLayout<io_string_t>.size) {
            if IORegistryEntryGetPath(self, kIOServicePlane, path) == KERN_SUCCESS {
                return String(cString: $0)
            }
            return nil
        }
    }
    
    /**
     - Returns: An NSNumber? representative of the USB product ID.
     - Note: See reference of USB Product IDs from the
     [Apple Wiki](https://theapplewiki.com/wiki/USB_Product_IDs). Note that
     devices return different productIDs when in Recovery Mode or DFU mode.
     - Warning: The result could be nil or could be a productID that is not
     from Apple. Double check that the device is what you think it is.
     */
    func productID() -> NSNumber? {
        let productCF = IORegistryEntryCreateCFProperty(self, "idProduct" as CFString, kCFAllocatorDefault, 0)
        return productCF?.takeRetainedValue() as? NSNumber
    }
    
    /**
     - Returns: YES if the device's productID is in the list of known iPhones.
     */
    func isIPhone() -> Bool {
        guard let productID = self.productID() else { return false }
        return IPhoneProductIDs.contains(Int(truncating: productID))
    }
    
    /**
     - Returns: YES if the device's productID is in the list of known recovery
     modes.
     - Note: See global list `RecoveryProductIDs`.
     */
    func isInRecoveryMode() -> Bool {
        guard let productID = self.productID() else { return false }
        return RecoveryProductIDs.contains(Int(truncating: productID))
    }
    
    /**
     - Returns: YES if the device's productID is in the list of known DFU modes.
     - Note: See global list `DFUProductIDs`.
     */
    func isInDFUMode() -> Bool {
        guard let productID = productID() else { return false }
        return DFUProductIDs.contains(Int(truncating: productID))
    }
    
    /**
     Obtains the a plugin interface for the kIOUSBDeviceUserClientTypeID service.
     - Returns: An optional double pointer to the IOCFPlugInInterface.
     */
    func pluginInterface() -> UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>? {
        var pluginInterfacePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOCFPlugInInterface>?>? = nil
        var score: Int32 = 0
        
        let kr = IOCreatePlugInInterfaceForService(
            self,
            kIOUSBDeviceUserClientTypeID,
            kIOCFPlugInInterfaceID,
            &pluginInterfacePtrPtr,
            &score
        )
        
        guard kr == kIOReturnSuccess else {
            return nil
        }
        return pluginInterfacePtrPtr
    }
    
    /**
     Obtains the device's interface from the plugin interface.
     - Returns: An optional double pointer to the IOUSBDeviceInterface.
     */
    func deviceInterface() -> UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>? {
        // First get the plugin interface.
        guard let pluginInterfacePtrPtr = self.pluginInterface(),
              let pluginInterfacePtr = pluginInterfacePtrPtr.pointee else {
            print("Could not get plugin interface pointee, exiting.")
            return nil
        }
        print("[+] Got plugin interface, continuing...")
        
        // Now query for the device interface.
        var deviceInterfacePtrPtr: UnsafeMutablePointer<UnsafeMutablePointer<IOUSBDeviceInterface>?>?
        let queryResult = withUnsafeMutablePointer(to: &deviceInterfacePtrPtr) {
            $0.withMemoryRebound(to: Optional<LPVOID>.self, capacity: 1) { rawPtr in
                // QueryInterface expects a pointer to a raw pointer.
                pluginInterfacePtr.pointee.QueryInterface(
                    pluginInterfacePtrPtr,
                    CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID),
                    rawPtr
                )
            }
        }
        guard queryResult == kIOReturnSuccess,
              let deviceInterfacePtr = deviceInterfacePtrPtr,
              deviceInterfacePtr.pointee != nil else {
            fatalError("Unable to get device interface, error: \(queryResult)")
        }
        return deviceInterfacePtr
    }
}
