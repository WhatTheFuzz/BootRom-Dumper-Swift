//
//  test_shellcode.swift
//  BootRom Dumper Swift
//
//  Created by Sean Deaton on 3/24/25.
//

import Testing
@testable import BootRomDumperFramework

struct test_shellcode {
    
    let bundleName = "com.seandeaton.BootRomDumperFramework"
    let bundle: Bundle
    let path: URL
    
    init() {
        guard let bundle = Bundle(identifier: bundleName),
              let url = bundle.url(forResource: "payload", withExtension: "o") else {
            fatalError("Could not load required resources.")
        }
        self.bundle = bundle
        self.path = url
    }
    
    @Test("Can open and read shellcode.")
    func test_readShellcode() {
        let bytes = readShellcode(from: self.path)
        #expect(bytes != nil)
        #expect(bytes!.count > 0)
    }
}
