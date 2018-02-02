//
//  ViewController.swift
//  EnchantedRoseBLE
//
//  Created by Steve Murch on 1/31/18.
//  Copyright © 2018 Steve Murch. All rights reserved.
//

import UIKit
import WebKit


// Petal - L{pin}{value}
// Light - H{value}     (0 = off, 1 = Dim, 2 = Pulse)
// Reset - K  (kill)
// General Text -
//

class ViewController: UIViewController, BLEDelegate {
    func bleDidUpdateState() {
        print("bleDidUpdateState")
    }
    
    func bleDidConnectToPeripheral() {
        print("bleDidConnectToPeripheral")
    }
    
    func bleDidDisconenctFromPeripheral() {
        print("bleDidDisconenctFromPeripheral")
    }
    
    func bleDidReceiveData(data: NSData?) {
        print("bleDidReceiveData")
    }
    

    var ble = BLE()
    
    
    
    // User Interface
    
    @IBOutlet weak var lblConnectionStatus: UILabel!
    
    

    
    @IBAction func resetProp(_ sender: Any) {
        
        
        let refreshAlert = UIAlertController(title: "Reset Enchanted Rose", message: "Are you sure? Do not use this DURING a performance.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            print("Handle Ok logic here")
            
            // send a K
           
            let dataPinLow = NSData(bytes: [0x4B] as [UInt8], length: 1)
            self.ble.write(data: dataPinLow)
            
            self.petal1Slider.value = 0
            self.petal2Slider.value = 0
            self.petal3Slider.value = 0
            self.petal4Slider.value = 0
            
            self.turnOffLight()
            self.lightSegmentedControl.selectedSegmentIndex = 0
            
            
            
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            print("Handle Cancel Logic here")
        }))
        
        present(refreshAlert, animated: true, completion: nil)
        
        
        
        
        
    }

    @IBOutlet weak var lightSegmentedControl: UISegmentedControl!
    
    func turnOffLight()
    {
        let payload = NSData(bytes: [0x48, 0x00] as [UInt8], length: 2)
        
        ble.write(data: payload)
    }
    
    @IBAction func lightSegmentedControlChanged(_ sender: Any) {
        
        print("light changed; send an H")
        
        var lightValue:UInt8 = 0
        switch(lightSegmentedControl.selectedSegmentIndex)
        {
        case 0: lightValue = 0
        break
        case 1: lightValue = 1
        break
        case 2:
            lightValue = 2
            break
        default:
            lightValue = 0
        }
       
        
        let payload = NSData(bytes: [0x48, lightValue] as [UInt8], length: 2)
        
        ble.write(data: payload)
        
        
    }
    
    @IBOutlet weak var petal1Slider: UISlider!
    @IBOutlet weak var petal2Slider: UISlider!
    @IBOutlet weak var petal3Slider: UISlider!
    @IBOutlet weak var petal4Slider: UISlider!

    
    // pin 2
    @IBAction func petal1Slid(_ sender: Any) {
        // send it -- L followed by value
        let valInt = UInt8(petal1Slider.value)
        let petalPayload = NSData(bytes: [0x4C, 0x02, valInt] as [UInt8], length: 3)
        ble.write(data: petalPayload)
    }
    
    // pin3
    @IBAction func petal2Slid(_ sender: Any) {
        let valInt = UInt8(petal2Slider.value)
        let petalPayload = NSData(bytes: [0x4C, 0x03, valInt] as [UInt8], length: 3)
        ble.write(data: petalPayload)

    }
    
    // pin 4
    @IBAction func petal3Slid(_ sender: Any) {
        let valInt = UInt8(petal3Slider.value)
        let petalPayload = NSData(bytes: [0x4C, 0x04, valInt] as [UInt8], length: 3)
        ble.write(data: petalPayload)
    }
    
    // pin 5
    @IBAction func petal4Slid(_ sender: Any) {
        let valInt = UInt8(petal4Slider.value)
        let petalPayload = NSData(bytes: [0x4C, 0x05, valInt] as [UInt8], length: 3)
        ble.write(data: petalPayload)
    }
    
    
    // arduino servo pins are 2,3,4,5 -- corresponding to UX petal switches 1,2,3,4
    
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBAction func toggleHelp(_ sender: Any) {
        
        let htmlPath = Bundle.main.path(forResource: "overview", ofType: "html")
        
        let url = URL(fileURLWithPath: htmlPath!)
        
        let request = URLRequest(url: url)
        webView.load(request)
        webView.isHidden = !webView.isHidden
    }
    
    
    func setStatusText(string: String)
    {
        self.lblConnectionStatus!.text = string
    }
    
    
    func sendDataToBLE(data: NSData) -> Bool {
        
        let dataPin7High = NSData(bytes: [0x54, 0x07, 0x01] as [UInt8], length: 3)
        
        ble.write(data: dataPin7High)
        
        return true
        
        
    }
    
    // servo pins are 2, 3, 4 and 5
    
    
    
    
    @IBAction func writeDataClicked(_ sender: Any) {
        
        //let commandData = mystring.data(using:.utf8)
        
        // command to T 7 1  (seT digital pin 7 to HIGH)
        let dataPin7High = NSData(bytes: [0x54, 0x0D, 0x01] as [UInt8], length: 3)
        
        ble.write(data: dataPin7High)
        
        sleep(1)
        
        // command to T 7 1  (seT digital pin 7 to HIGH)
        let dataPin7Low = NSData(bytes: [0x54, 0x07, 0x00] as [UInt8], length: 3)
        
        ble.write(data: dataPin7Low)
        
    }
    
    func updateConnectionLabel(data: String)
    {
        self.lblConnectionStatus.text = data
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ble.delegate = self
        
        //print("Disconnecting all...")
        ble.disconnectAll()
        
        
        
        //print("viewDidLoad")
        
        ble.onDataUpdate = { [weak self] (data: String) in
            self?.updateConnectionLabel(data: data)
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

