/*
 Copyright (c) 2015 Fernando Reynoso
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

import Foundation
import CoreBluetooth

protocol BLEDelegate {
    func bleDidUpdateState()
    func bleDidConnectToPeripheral()
    func bleDidDisconenctFromPeripheral()
    func bleDidReceiveData(data: NSData?)
}

class BLE: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var onDataUpdate: ((_ data: String) -> Void)?
    
    let RBL_SERVICE_UUID = "713D0000-503E-4C75-BA94-3148F18D941E"
    let RBL_CHAR_TX_UUID = "713D0002-503E-4C75-BA94-3148F18D941E"
    let RBL_CHAR_RX_UUID = "713D0003-503E-4C75-BA94-3148F18D941E"
    
    var delegate: BLEDelegate?
    
    private      var centralManager:   CBCentralManager!
    private      var activePeripheral: CBPeripheral?
    private      var characteristics = [String : CBCharacteristic]()
    private      var data:             NSMutableData?
    private(set) var peripherals     = [CBPeripheral]()
    private      var RSSICompletionHandler: ((NSNumber?, NSError?) -> ())?
    
    override init() {
        super.init()
        
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.data = NSMutableData()
    }
    
    @objc private func scanTimeout() {
        
        print("[DEBUG] Scanning stopped")
        
        self.centralManager.stopScan()
        
        
    }
    
    // MARK: Public methods
    
    func disconnectAll() -> Bool {
     
        if (self.activePeripheral != nil)
        {
            _ = self.disconnectFromPeripheral(peripheral: self.activePeripheral!)
        }
        
        onDataUpdate?("Disconnecting")
        
        return true
    }
    
    
    func startScanning(timeout: Double) -> Bool {
        
        if self.centralManager.state != .poweredOn {
            
            print("[ERROR] Couldn´t start scanning")
            onDataUpdate?("Couldn't start scanning")
            return false
        }
        
        print("[DEBUG] Scanning has started")
        onDataUpdate?("Scanning... Is prop powered on?")
        
        // CBCentralManagerScanOptionAllowDuplicatesKey
        
        // set the timeout for when to give up
        Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(BLE.scanTimeout), userInfo: nil, repeats: false)
        
        let services:[CBUUID] = [CBUUID(string: RBL_SERVICE_UUID)]
        self.centralManager.scanForPeripherals(withServices: services, options: nil)
        
        
        
        return true
    }
    
    func connectToPeripheral(peripheral: CBPeripheral) -> Bool {
        
        if self.centralManager.state != .poweredOn {
            
            print("[ERROR] Couldn´t connect to peripheral")
            onDataUpdate?("Could not connect")
            return false
        }
        
        print("[DEBUG] Connecting to peripheral: \(peripheral.identifier.uuidString)")
        
        self.centralManager.connect(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey : NSNumber(value: true)])
        
        return true
    }
    
    func disconnectFromPeripheral(peripheral: CBPeripheral) -> Bool {
        
        if self.centralManager.state != .poweredOn {
            onDataUpdate?("Could not disconnect")
            print("[ERROR] Couldn´t disconnect from peripheral")
            return false
        }
        
        self.centralManager.cancelPeripheralConnection(peripheral)
        
        return true
    }
    
    func read() {
        
        guard let char = self.characteristics[RBL_CHAR_TX_UUID] else { return }
        
        self.activePeripheral?.readValue(for: char)
    }
    
    func write(data: NSData) {
        
        guard let char = self.characteristics[RBL_CHAR_RX_UUID] else { return }
        
        self.activePeripheral?.writeValue(data as Data, for: char, type: .withoutResponse)
        
    }
    
    func enableNotifications(enable: Bool) {
        
        guard let char = self.characteristics[RBL_CHAR_TX_UUID] else { return }
        
        self.activePeripheral?.setNotifyValue(enable, for: char)
    }
    
    func readRSSI(completion: @escaping (_ RSSI: NSNumber?, _ error: NSError?) -> ()) {
        
        self.RSSICompletionHandler = completion
        self.activePeripheral?.readRSSI()
    }
    
    // MARK: CBCentralManager delegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .unknown:
            print("[DEBUG] Central manager state: Unknown")
            onDataUpdate?("State unknown")
            break
            
        case .resetting:
            print("[DEBUG] Central manager state: Resetting")
            onDataUpdate?("Resetting")
            
            
            
            break
            
        case .unsupported:
            print("[DEBUG] Central manager state: Unsupported")
            onDataUpdate?("State unsupported")
            break
            
        case .unauthorized:
            print("[DEBUG] Central manager state: Unauthorized")
            onDataUpdate?("Unauthorized")
            
            break
            
        case .poweredOff:
            print("[DEBUG] Central manager state: Powered off")
            onDataUpdate?("POWERED OFF")
            
            break
            
        case .poweredOn:
            print("[DEBUG] Central manager state: Powered on")
            onDataUpdate?("Scanning...")
            
            _ = startScanning(timeout: 60)
            break
        }
        
        self.delegate?.bleDidUpdateState()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("[DEBUG] Did Discover \(String(describing: peripheral.name)) \(peripheral.identifier.uuidString) RSSI: \(RSSI)")
        onDataUpdate?("Discovered peripheral")
        
        let index = peripherals.index { $0.identifier.uuidString == peripheral.identifier.uuidString }
        
        if let index = index {
            peripherals[index] = peripheral
        } else {
            peripherals.append(peripheral)
        }
        
        peripheral.delegate = self as CBPeripheralDelegate
        self.centralManager.connect(peripheral, options:nil)
        
        
        
        
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        
        
        print("[DEBUG] Connected to peripheral \(peripheral.identifier.uuidString)")
        
        onDataUpdate?("CONNECTED")
        
        
        self.activePeripheral = peripheral
        
        self.activePeripheral?.delegate = self
        self.activePeripheral?.discoverServices([CBUUID(string: RBL_SERVICE_UUID)])
        
        self.delegate?.bleDidConnectToPeripheral()
        
        
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print("[DEBUG] Did discover services 2")
        
        onDataUpdate?("Ready!")
        if error != nil {
            print("[ERROR] Error discovering services. \(error!.localizedDescription)")
            return
        }
        
        print("[DEBUG] Found services for peripheral: \(peripheral.identifier.uuidString)")
        
        
        for service in peripheral.services! {
            let theCharacteristics = [CBUUID(string: RBL_CHAR_RX_UUID), CBUUID(string: RBL_CHAR_TX_UUID)]
            
            peripheral.discoverCharacteristics(theCharacteristics, for: service)
        }
    }
    
    
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject],RSSI: NSNumber) {
        print("[DEBUG] Find peripheral: \(peripheral.identifier.uuidString) RSSI: \(RSSI)")
        
        let index = peripherals.index { $0.identifier.uuidString == peripheral.identifier.uuidString }
        
        if let index = index {
            peripherals[index] = peripheral
        } else {
            peripherals.append(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("[ERROR] Could not connect to peripheral \(peripheral.identifier.uuidString) error: \(error!.localizedDescription)")
        onDataUpdate?("Could not connect")
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        print("[DEBUG] Connected to peripheral \(peripheral.identifier.uuidString)")
        
        self.activePeripheral = peripheral
        
        self.activePeripheral?.delegate = self
        self.activePeripheral?.discoverServices([CBUUID(string: RBL_SERVICE_UUID)])
        
        self.delegate?.bleDidConnectToPeripheral()
        onDataUpdate?("Connected")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        var text = "[DEBUG] Disconnected from peripheral: \(peripheral.identifier.uuidString)"
        onDataUpdate?("DISCONNECTED")
        
        if error != nil {
            text += ". Error: \(error!.localizedDescription)"
        }
        
        print(text)
        
        self.activePeripheral?.delegate = nil
        self.activePeripheral = nil
        self.characteristics.removeAll(keepingCapacity: false)
        
        self.delegate?.bleDidDisconenctFromPeripheral()
    }
    
    // MARK: CBPeripheral delegate
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if error != nil {
            print("[ERROR] Error discovering services. \(error!.description)")
            onDataUpdate?("Error discovering services")
            return
        }
        
        print("[DEBUG] Found services for peripheral: \(peripheral.identifier.uuidString)")
        
        
        for service in peripheral.services! {
            let theCharacteristics = [CBUUID(string: RBL_CHAR_RX_UUID), CBUUID(string: RBL_CHAR_TX_UUID)]
            
            peripheral.discoverCharacteristics(theCharacteristics, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
            print("[ERROR] Error discovering characteristics. \(error!.localizedDescription)")
            onDataUpdate?("Error discovering characteristics")
            return
        }
        
        print("[DEBUG] Found characteristics for peripheral: \(peripheral.identifier.uuidString)")
        
        for characteristic in service.characteristics! {
            self.characteristics[characteristic.uuid.uuidString] = characteristic
        }
        
        enableNotifications(enable: true)
    }
    
    
    
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            onDataUpdate?("Error updating value")
            print("[ERROR] Error updating value. \(error!.localizedDescription)")
            return
        }
        
        if characteristic.uuid.uuidString == RBL_CHAR_TX_UUID {
            print(characteristic.value!)
            self.delegate?.bleDidReceiveData(data: characteristic.value as NSData?)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        self.RSSICompletionHandler?(RSSI, error! as NSError)
        self.RSSICompletionHandler = nil
    }
}
