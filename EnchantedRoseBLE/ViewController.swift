//
//  ViewController.swift
//  EnchantedRoseBLE
//
//  Created by Steve Murch on 1/31/18.
//  Copyright © 2018 Steve Murch. All rights reserved.
//

import UIKit
import PDColorPicker

// Petal - L{pin}{value}
// Light - H{value}     (0 = off, 1 = Dim, 2 = Pulse)
// Reset - K  (kill)
// General Text -
// Set Color: C

class ViewController: UIViewController, BLEDelegate, Dimmable {
    
    
    func bleDidUpdateState() {
        print("bleDidUpdateState")
    }
    
    func bleDidConnectToPeripheral() {
        print("bleDidConnectToPeripheral")
        roseColorUIImageView.isHidden = false
        roseBWUIImageVIew.isHidden = true
    }
    
    func bleDidDisconnectFromPeripheral() {
        print("bleDidDisconnectFromPeripheral")
        roseColorUIImageView.isHidden = true
        roseBWUIImageVIew.isHidden = false
    }
    
    func bleDidReceiveData(data: NSData?) {
        print("bleDidReceiveData")
        if let datastring = NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)
        {
            lblConnectionStatus.text = datastring as String
        }
    }
  
    
    // User Interface
    @IBOutlet weak var roseBWUIImageVIew: UIImageView!
    @IBOutlet weak var roseColorUIImageView: UIImageView!
    @IBOutlet weak var lblConnectionStatus: UILabel!
    @IBOutlet weak var lblSliderTip: UILabel!
    
    
    @IBOutlet weak var colorButton: UIButton!
    
    func getBle() -> BLE {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.ble
    }
    
    func presentColorPicker() {
        // 2.
        
        let defaults = UserDefaults.standard
        var initialColor: UIColor = .red
        
        if let savedColor = defaults.colorForKey(key: "neoPixelColor") {
            initialColor = savedColor
        }
        
        let colorPickerVC = PDColorPickerViewController(initialColor: initialColor, tintColor: .black)
        
        // 3.
        colorPickerVC.completion = {
            [weak self] newColor in
            
            self?.undim() // 7.
            
            guard let color = newColor else {
                print("The user tapped cancel, no color was selected.")
                return
            }
            
            print("A new color was selected! HSBA: \(String(describing: color))")
            
            // send to device
            let r = UInt8(color.rgba.r * 255)
            let g = UInt8(color.rgba.g * 255)
            let b = UInt8(color.rgba.b * 255)
            
            // send a C (color) followed by 3 bytes
            let colorPayload = NSData(bytes: [0x43, r, g, b] as [UInt8], length: 4)
            self?.getBle().write(data: colorPayload)
            self?.lightSegmentedControl.selectedSegmentIndex = 1
            
            self?.colorButton.backgroundColor = color.uiColor
            
            let defaults = UserDefaults.standard
            
            defaults.setColor(color: color.uiColor, forKey: "neoPixelColor")
            
            
        }
        
        // 4.
        dim() // see Dimmable documentation for extra options
        
        // 5.
        present(colorPickerVC, animated: true)
    }
    
    
    @IBAction func resetProp(_ sender: Any) {

        let refreshAlert = UIAlertController(title: "Reset Enchanted Rose", message: "Are you sure? Do not use this DURING a performance.", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
           
            // send a K
            let dataPinLow = NSData(bytes: [0x4B] as [UInt8], length: 1)
            self.getBle().write(data: dataPinLow)
            
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
        
        getBle().write(data: payload)
    }
    
    @IBAction func lightSegmentedControlChanged(_ sender: Any) {
        
        print("light changed; send an H")
        
        var lightValue:UInt8 = 0
        switch(lightSegmentedControl.selectedSegmentIndex)
        {
        case 0: lightValue = 0
        break
        case 1: lightValue = 1 // ON to saved color
        

            let defaults = UserDefaults.standard
            var initialColor: UIColor = .red
            
            if let savedColor = defaults.colorForKey(key: "neoPixelColor") {
                initialColor = savedColor
            }
            
            // send to device
            let r = UInt8(CIColor(color:initialColor).red*255)
            let g = UInt8(CIColor(color:initialColor).green*255)
            let b = UInt8(CIColor(color:initialColor).blue*255)
            
            // send a C (color) followed by 3 bytes
            let colorPayload = NSData(bytes: [0x43, r, g, b] as [UInt8], length: 4)
            self.getBle().write(data: colorPayload)
            self.lightSegmentedControl.selectedSegmentIndex = 1
            return;
            
        
        
        case 2:
            lightValue = 2
            break
        default:
            lightValue = 0
        }
        
        let payload = NSData(bytes: [0x48, lightValue] as [UInt8], length: 2)
        getBle().write(data: payload)

    }
    
    @IBOutlet weak var petal1Slider: UISlider!
    @IBOutlet weak var petal2Slider: UISlider!
    @IBOutlet weak var petal3Slider: UISlider!
    @IBOutlet weak var petal4Slider: UISlider!
   
    
    // The tag value of the slider indicates which Pin on the Arduino should be moved
    // arduino servo pins are 2,3,4,5 -- corresponding to UX petal switches 1,2,3,4

    @IBAction func petalSlider(_ sender: UISlider) {
        print(sender.tag)
        
        let pinNo = UInt8(sender.tag)
        
        let valInt = UInt8(sender.value)
        let petalPayload = NSData(bytes: [0x4C, pinNo, valInt] as [UInt8], length: 3)
        getBle().write(data: petalPayload)
        
        if (valInt<170) && (valInt>10)
        {
            showSliderTip()
        } else
        {
            hideSliderTip()
        }
        
        
        
    }
    
    
    
    @IBAction func setLightToColor(_ sender: Any) {
        
        presentColorPicker()
    }
    
    
    
    func setStatusText(string: String)
    {
        self.lblConnectionStatus!.text = string
    }
    
    
    func sendDataToBLE(data: NSData) -> Bool {
        let dataPin7High = NSData(bytes: [0x54, 0x07, 0x01] as [UInt8], length: 3)
        getBle().write(data: dataPin7High)
        return true
    }
    
    func showSliderTip()
    {
        lblSliderTip.isHidden = false
    }
    
    func hideSliderTip()
    {
        lblSliderTip.isHidden = true
    }
    
    // servo pins are 2, 3, 5 and 6
    
    @IBAction func writeDataClicked(_ sender: Any) {
        
        //let commandData = mystring.data(using:.utf8)
        
        // command to T 7 1  (seT digital pin 7 to HIGH)
        let dataPin7High = NSData(bytes: [0x54, 0x0D, 0x01] as [UInt8], length: 3)
        
        getBle().write(data: dataPin7High)
        sleep(1)
        
        // command to T 7 1  (seT digital pin 7 to HIGH)
        let dataPin7Low = NSData(bytes: [0x54, 0x07, 0x00] as [UInt8], length: 3)
        
        getBle().write(data: dataPin7Low)
        
    }
    
    func updateConnectionLabel(data: String)
    {
        self.lblConnectionStatus.text = data
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let initialColor = defaults.colorForKey(key: "neoPixelColor") {
            
            self.colorButton.backgroundColor = initialColor
        }
        else {
            self.colorButton.backgroundColor = .blue
            defaults.setColor(color: .blue, forKey: "neoPixelColor")
            
        }
            
        // Do any additional setup after loading the view, typically from a nib.
        
        getBle().delegate = self // I'd like to receive messages from BLE device
        
        
        //_ = getBle().disconnectAll() // reset
        
        getBle().onDataUpdate = { [weak self] (data: String) in
            
            // when a data update is received, push it to screen
            
            self?.updateConnectionLabel(data: data)
        }
        
        if (getBle().isConnected)
        {
            self.roseBWUIImageVIew.isHidden = true
            self.roseColorUIImageView.isHidden = false
        } else
        {
            self.roseBWUIImageVIew.isHidden = false
            self.roseColorUIImageView.isHidden = true
        }
        
        
        
        
  
    }
    
    @objc func ef_dismissViewController(sender: Any){
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}


extension UserDefaults {
    func colorForKey(key: String) -> UIColor? {
        var color: UIColor?
        if let colorData = data(forKey: key) {
            color = NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
        }
        return color
    }
    
    func setColor(color: UIColor?, forKey key: String) {
        var colorData: NSData?
        if let color = color {
            colorData = NSKeyedArchiver.archivedData(withRootObject: color) as NSData?
        }
        set(colorData, forKey: key)// UserDefault Built-in Method into Any?
    }
}

