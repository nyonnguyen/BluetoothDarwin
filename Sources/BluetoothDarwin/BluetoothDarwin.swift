//
//  BluetoothDarwin.swift
//  PureSwift
//
//  Created by Alsey Coleman Miller on 3/25/18.
//  Copyright © 2018 PureSwift. All rights reserved.
//

import Foundation
import IOBluetooth
import CBluetoothDarwin
import Bluetooth

public struct BluetoothHCICommandRequest: RawRepresentable {
    
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

/// IOBluetoothHostController::SendRawHCICommand(unsigned int, char*, unsigned int, unsigned char*, unsigned int)
public func BluetoothHCISendRawCommand(request: BluetoothHCICommandRequest,
                                       commandData: Data,
                                       returnParameter outputData: inout Data) -> CInt {
    
    assert(commandData.isEmpty == false)
    
    var request = request.rawValue
    var commandData = commandData
    var commandSize = commandData.count
    var returnParameter = outputData
    
    var dispatchParameters = IOBluetoothHCIDispatchParams()
    
    withUnsafePointer(to: &request, { dispatchParameters.args.0 = UInt64(uintptr_t(bitPattern: $0)) })
    commandData.withUnsafeBytes { dispatchParameters.args.1 = UInt64(uintptr_t(bitPattern: $0)) }
    withUnsafePointer(to: &commandSize, { dispatchParameters.args.2 = UInt64(uintptr_t(bitPattern: $0)) })
    
    dispatchParameters.sizes.0 = UInt64(MemoryLayout<UInt32>.size) // sizeof(uint32);
    dispatchParameters.sizes.1 = UInt64(commandSize)
    dispatchParameters.sizes.2 = UInt64(MemoryLayout<uintptr_t>.size) // sizeof(uintptr_t);
    dispatchParameters.index = 0x000060c000000062 // Method ID
    
    return returnParameter.withUnsafeMutableBytes {
        BluetoothHCIDispatchUserClientRoutine(&dispatchParameters, $0, returnParameter.count)
    }
}