//
//  ItemDetailViewController.swift
//  SehatQ
//
//  Created by JAN FREDRICK on 24/08/20.
//  Copyright © 2020 JFSK. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

import JGProgressHUD

var itemDictOfChoice : NSDictionary! = [:]
var choiceArray : NSMutableArray! = []

var controllerFrom : String = ""

class ItemDetailViewController : UIViewController {
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var descView: UITextView!
    @IBOutlet weak var priceL: UILabel!
    @IBOutlet weak var buyB: UIButton!
    @IBOutlet weak var heartB: UIButton!
    @IBOutlet weak var closeB: UIButton!
    @IBOutlet weak var shareB: UIButton!
    
    override func viewDidLoad() {
        
        buyB.layer.borderColor = UIColor.black.cgColor
        buyB.layer.borderWidth = 1.0
        
        closeB.backgroundColor = UIColor(white: 0, alpha: 0.5)
        shareB.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        heartB.setTitleColor(UIColor.clear, for: .normal)
        heartB.setTitle(itemDictOfChoice["id"] as? String, for: .normal)
        
        if itemDictOfChoice["loved"] as! Int == 1 {
            heartB.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            heartB.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
        AF.request(itemDictOfChoice["imageUrl"] as! String).responseData {
            (response) in
            if response.error == nil {
                if let data = response.data {
                    self.imageView.image = UIImage(data: data)
                }
            }else{
                print("error : \(String(describing: response.error?.localizedDescription))")
            }
        }
        
        nameL.text = itemDictOfChoice["title"] as? String
        descView.text = itemDictOfChoice["description"] as? String
        priceL.text = itemDictOfChoice["price"] as? String
        
        if controllerFrom == "PurchaseHistory" {
            heartB.isHidden = true
            buyB.setTitle("BOUGHT", for: .normal)
            buyB.isUserInteractionEnabled = false
        }
        
    }
    
    @IBAction func closeItemDetail(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareItem(_ sender: Any) {
        //sharing to whatsapp
    }
    
    @IBAction func heartUnHeart(_ sender: UIButton) {
        if sender.imageView?.image == UIImage(systemName: "heart") {
            setHeart(withId: sender.titleLabel!.text!)
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            unHeart(withId: sender.titleLabel!.text!)
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
        }
    }
    
    func setHeart(withId : String) {
        for i in 0..<choiceArray.count {
            
            let nextDict = (choiceArray[i] as! NSDictionary).mutableCopy() as! NSMutableDictionary
            
            if nextDict["id"] as! String == withId {
                nextDict.setValue(1, forKey: "loved")
                choiceArray.replaceObject(at: i, with: nextDict as NSDictionary)
                break
            }
            
        }
    }
    
    func unHeart(withId : String) {
        for i in 0..<choiceArray.count {
            
            let nextDict = (choiceArray[i] as! NSDictionary).mutableCopy() as! NSMutableDictionary
            
            if nextDict["id"] as! String == withId {
                nextDict.setValue(0, forKey: "loved")
                choiceArray.replaceObject(at: i, with: nextDict as NSDictionary)
                break
            }
            
        }
    }
    
    let hud = JGProgressHUD(style: .light)
    
    @IBAction func buyNow(_ sender: Any) {
        //adding to purchase history
        purchasedArray.add(itemDictOfChoice!)
        print("use: \(purchasedArray.count)")
        hud.textLabel.text = "Item '\(String(describing: itemDictOfChoice["title"] as! String))' has been purchased. \(String(describing: itemDictOfChoice["price"] as! String)) has been deducted from your wallet. Thank you."
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 4.0, animated: true)
    }
}
