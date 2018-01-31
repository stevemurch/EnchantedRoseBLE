//
//  ViewController.swift
//  EnchantedRoseBLE
//
//  Created by Steve Murch on 1/31/18.
//  Copyright © 2018 Steve Murch. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var ble = BLE()
    
    @IBOutlet weak var commandText: UITextField!
    
    @IBAction func writeDataClicked(_ sender: Any) {
        
        let mystring = commandText.text!
        let commandData = mystring.data(using:.utf8)
        
        // command to T 7 1  (seT digital pin 7 to HIGH)
        let dataPin7High = NSData(bytes: [0x54, 0x07, 0x01] as [UInt8], length: 3)
        
        ble.write(data: dataPin7High)
        
        sleep(1)
        
        // command to T 7 1  (seT digital pin 7 to HIGH)
        let dataPin7Low = NSData(bytes: [0x54, 0x07, 0x00] as [UInt8], length: 3)
        
        ble.write(data: dataPin7Low)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

