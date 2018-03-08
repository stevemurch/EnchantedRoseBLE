//
//  CalibrationViewController.swift
//  EnchantedRoseBLE
//
//  Created by Steve Murch on 2/8/18.
//  Copyright © 2018 Steve Murch. All rights reserved.
//

import UIKit

class CalibrationViewController: UIViewController {

    @IBOutlet weak var segmentedControlReadyDrop: UISegmentedControl!
    
    
    
    @IBOutlet weak var min1Label: UILabel!
    @IBOutlet weak var min2Label: UILabel!
    @IBOutlet weak var min3Label: UILabel!
    @IBOutlet weak var min4Label: UILabel!
    
    @IBOutlet weak var max1Label: UILabel!
    @IBOutlet weak var max2Label: UILabel!
    @IBOutlet weak var max3Label: UILabel!
    @IBOutlet weak var max4Label: UILabel!
    
    
    @IBOutlet weak var sliderPetal1: UISlider!
    
    @IBOutlet weak var sliderPetal2: UISlider!
    
    @IBOutlet weak var sliderPetal3: UISlider!
    
    @IBOutlet weak var sliderPetal4: UISlider!
    
    @IBAction func btnSave(_ sender: Any) {
        
        
    }
    
    func getBle() -> BLE {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.ble
    }
    
       
    @IBAction func slider1Moved(sender: UISlider) {
        
        // send movement
        let pinNo = UInt8(sender.tag)
        let valInt = UInt8(sender.value)
        let petalPayload = NSData(bytes: [0x4C, pinNo, valInt] as [UInt8], length: 3)
        getBle().write(data: petalPayload)
        
        if (segmentedControlReadyDrop.selectedSegmentIndex == 0)
        {
            // ready (min)
            min1Label.text = String(Int(sliderPetal1.value))
        } else
        {
            // drop (max)
            max1Label.text = String(Int(sliderPetal1.value))
        }
        
        
    }
    @IBAction func slider2Moved(_ sender: UISlider) {
        // send movement
        let pinNo = UInt8(sender.tag)
        let valInt = UInt8(sender.value)
        let petalPayload = NSData(bytes: [0x4C, pinNo, valInt] as [UInt8], length: 3)
        getBle().write(data: petalPayload)
        
        if (segmentedControlReadyDrop.selectedSegmentIndex == 0)
        {
            // ready (min)
            min2Label.text = String(Int(sliderPetal2.value))
        } else
        {
            // drop (max)
            max2Label.text = String(Int(sliderPetal2.value))
            
        }
        
    }
    @IBAction func slider3Moved(_ sender: UISlider) {
        // send movement
        let pinNo = UInt8(sender.tag)
        let valInt = UInt8(sender.value)
        let petalPayload = NSData(bytes: [0x4C, pinNo, valInt] as [UInt8], length: 3)
        getBle().write(data: petalPayload)
        
        if (segmentedControlReadyDrop.selectedSegmentIndex == 0)
        {
            // ready (min)
            min3Label.text = String(Int(sliderPetal3.value))
        } else
        {
            // drop (max)
            max3Label.text = String(Int(sliderPetal3.value))
            
        }
        
    }
    @IBAction func slider4Moved(_ sender: UISlider) {
        // send movement
        let pinNo = UInt8(sender.tag)
        let valInt = UInt8(sender.value)
        let petalPayload = NSData(bytes: [0x4C, pinNo, valInt] as [UInt8], length: 3)
        getBle().write(data: petalPayload)
        
        if (segmentedControlReadyDrop.selectedSegmentIndex == 0)
        {
            // ready (min)
            min4Label.text = String(Int(sliderPetal4.value))
        } else
        {
            // drop (max)
            max4Label.text = String(Int(sliderPetal4.value))
            
        }
    }
    
    
    @IBAction func segmentedControlReadyDropChanged(_ sender: Any) {
        loadSliderState()
    }
    
    func saveSliderState()
    {
        let defaults = UserDefaults.standard
        
        if (segmentedControlReadyDrop.selectedSegmentIndex==0)
        {
            // save Ready position (min)
            defaults.set(sliderPetal1.value, forKey:"min1")
            defaults.set(sliderPetal2.value, forKey:"min2")
            defaults.set(sliderPetal3.value, forKey:"min3")
            defaults.set(sliderPetal4.value, forKey:"min4")
        } else
        {
            // save Drop Position (max)
            defaults.set(sliderPetal1.value, forKey:"max1")
            defaults.set(sliderPetal2.value, forKey:"max2")
            defaults.set(sliderPetal3.value, forKey:"max3")
            defaults.set(sliderPetal4.value, forKey:"max4")
            
        }
    }
    
    func loadSliderState()
    {
        let defaults = UserDefaults.standard

        let min1 = defaults.integer(forKey:"min1")
        let min2 = defaults.integer(forKey:"min2")
        let min3 = defaults.integer(forKey:"min3")
        let min4 = defaults.integer(forKey:"min4")
        
        if (defaults.integer(forKey:"max1") == 0)
        {
            defaults.set(180, forKey:"max1")
        }
        let max1 = defaults.integer(forKey:"max1")
        if (defaults.integer(forKey:"max2") == 0)
        {
            defaults.set(180, forKey:"max2")
        }
        let max2 = defaults.integer(forKey:"max2")
        if (defaults.integer(forKey:"max3") == 0)
        {
            defaults.set(180, forKey:"max3")
        }
        let max3 = defaults.integer(forKey:"max3")
        if (defaults.integer(forKey:"max4") == 0)
        {
            defaults.set(180, forKey:"max4")
        }
        let max4 = defaults.integer(forKey:"max4")
        
        
        if (segmentedControlReadyDrop.selectedSegmentIndex==0)
        {
            // ready
            sliderPetal1.value = Float(min1)
            sliderPetal2.value = Float(min2)
            sliderPetal3.value = Float(min3)
            sliderPetal4.value = Float(min4)
        
        } else
        {
            // drop
            sliderPetal1.value = Float(max1)
            sliderPetal2.value = Float(max2)
            sliderPetal3.value = Float(max3)
            sliderPetal4.value = Float(max4)
            
            
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadSliderState()
        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
