//
//  PurchaseHistoryViewController.swift
//  SehatQ
//
//  Created by JAN FREDRICK on 25/08/20.
//  Copyright © 2020 JFSK. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

var purchasedArray : NSMutableArray! = []

class PurchaseHistoryViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableViewHistory: UITableView!
    
    
    override func viewDidLoad() {
        
        tableViewHistory.delegate = self
        tableViewHistory.dataSource = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("pyr = \(purchasedArray.count)")
        tableViewHistory.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchasedArray.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemDictOfChoice = purchasedArray[indexPath.row] as? NSDictionary
        controllerFrom = "PurchaseHistory"
        performSegue(withIdentifier: "purchase_to_detail", sender: self)
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "history_cell") as! tbHistoCell
        
        let nextDict = purchasedArray[indexPath.row] as! NSDictionary
        
        AF.request(nextDict["imageUrl"] as! String).responseData {
            (response) in
            
            if response.error == nil {
                
                if let data = response.data {
                    cell.imageV.image = UIImage(data: data)
                }
                
            }else{
                print("image error = \(String(describing: response.error?.localizedDescription))")
            }
            
        }
        
        cell.nameL.text = nextDict["title"] as? String
        cell.priceL.text = nextDict["price"] as? String
        
        return cell
        
    }
    
}
