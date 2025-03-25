//
//  shellcode.swift
//  BootRom Dumper Swift
//
//  Created by Sean Deaton on 3/24/25.
//

import Foundation

func readShellcode(from url: URL) -> [UInt8]? {
    do {
        let fileContents = try Data(contentsOf: url)
        return [UInt8](fileContents)
    } catch {
        return nil
    }
}
