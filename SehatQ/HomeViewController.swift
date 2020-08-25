//
//  HomeViewController.swift
//  SehatQ
//
//  Created by JAN FREDRICK on 24/08/20.
//  Copyright © 2020 JFSK. All rights reserved.
//

import Foundation
import UIKit

import Alamofire
import SkeletonView
import JGProgressHUD

var homeCateArray : NSMutableArray = []
var homeTBArray : NSMutableArray = []

class HomeViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var categoriesSV: UIScrollView!
    
    @IBOutlet weak var tableViewHome: UITableView!
    
    var homeTBArrayChoice : NSMutableArray = []
    
    override func viewDidAppear(_ animated: Bool) {
        if choiceArray != [] {
            homeTBArrayChoice = choiceArray
            tableViewHome.reloadData()
        }
    }
    
    override func viewDidLoad() {
        
        //searchBar.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(touchOnSearchBar)))
        
        let touchB = UIButton(frame: CGRect(x: 0, y: 0, width: searchBar.frame.width, height: searchBar.frame.height))
        searchBar.addSubview(touchB)
        
        touchB.addTarget(self, action: #selector(touchOnSearchBar), for: .touchUpInside)
        
        // First come to home show all list
        
        tableViewHome.delegate = self
        tableViewHome.dataSource = self
        
        homeTBArrayChoice = homeTBArray
        
        //tableViewHome.reloadData()
        
        categoriesSV.backgroundColor = .white
        
        var oriX : CGFloat = 5
        let oriY : CGFloat = 5
        let bWidth : CGFloat = 50
        let bHeight : CGFloat = 70
        
        for i in 0..<homeCateArray.count {
            
            let nextDict = homeCateArray[i] as! NSDictionary
            
            let cateB = UIButtonWithDict(frame: CGRect(x: oriX, y: oriY, width: bWidth, height: bHeight))
            categoriesSV.addSubview(cateB)
            
            cateB.dict = nextDict
            cateB.addTarget(self, action: #selector(showArrayBasedOnCategoryId(sender:)), for: .touchUpInside)
            
            let cateImage = UIImageView(frame: CGRect(x: 0, y: 0, width: bWidth, height: bWidth))
            cateB.addSubview(cateImage)
            
            cateImage.backgroundColor = .brown
            cateImage.showAnimatedGradientSkeleton()
            
            AF.request((nextDict["imageUrl"] as? String)!).responseData {
                (response) in
                
                cateImage.hideSkeleton()
                cateImage.backgroundColor = .clear
                
                if response.error == nil {
                    if let data = response.data {
                        cateImage.image = UIImage(data: data)
                    }
                }else{
                    print("error image = \(String(describing: response.error))")
                }
            }
            
            let cateLabel = UILabel(frame: CGRect(x: 0, y: bWidth, width: bWidth, height: 20))
            cateB.addSubview(cateLabel)
            
            cateLabel.textAlignment = .center
            cateLabel.text = nextDict["name"] as? String
            cateLabel.font = UIFont.systemFont(ofSize: 14)
            cateLabel.adjustsFontSizeToFitWidth = true
            
            oriX += bWidth + oriY
            
        }
        
        categoriesSV.contentSize = CGSize(width: oriX, height: bHeight)
        
    }
    
    let hud = JGProgressHUD(style: .dark)
    
    @objc func showArrayBasedOnCategoryId(sender: UIButtonWithDict) {
        //show new array based on category id
        
        print("category id to search for new array = \(sender.dict["id"] as! Int)")
        
        hud.textLabel.text = "Category id \(sender.dict["id"] as! Int) representing \(sender.dict["name"] as! String), not found!"
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 4.0)
        
        print("should filter homeTBArray based on cate id and pass to homeTBArrayChoice")
        print("then should reload data of tableviewhome")
    }
    
    @objc func touchOnSearchBar() {
        print("search Bar Touched")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return homeTBArrayChoice.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        itemDictOfChoice = homeTBArrayChoice[indexPath.row] as? NSDictionary
        choiceArray = homeTBArrayChoice
        controllerFrom = "Home"
        performSegue(withIdentifier: "to_item_detail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "home_cell") as! tbCellHome
        
        let nextDict = homeTBArrayChoice[indexPath.row] as! NSDictionary
        
        cell.dict = nextDict
        
        cell.cellImage.backgroundColor = .brown
        cell.cellImage.showAnimatedGradientSkeleton()
        cell.cellImage.contentMode = .scaleAspectFill
        cell.cellImage.clipsToBounds = true
        
        AF.request((nextDict["imageUrl"] as? String)!).responseData {
            (response) in
            
            cell.cellImage.hideSkeleton()
            cell.cellImage.backgroundColor = .clear
            
            if response.error == nil {
                if let data = response.data {
                    cell.cellImage.image = UIImage(data: data)
                }
            }else{
                print("error image = \(String(describing: response.error))")
            }
            
        }
        
        cell.cellLabel.text = nextDict["title"] as? String
        if nextDict["loved"] as? Int == 1 {
            cell.cellLikeB.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }else{
            cell.cellLikeB.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        cell.cellLikeB.tag = indexPath.row
        cell.cellLikeB.addTarget(self, action: #selector(cellLikeBOnOff(sender:)), for: .touchUpInside)
        cell.cellLikeB.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        return cell
        
    }
    
    @objc func cellLikeBOnOff(sender: UIButtonWithDict) {
        
        print("like button with row = \(sender.tag)")
        
        if sender.imageView!.image == UIImage(systemName: "heart.fill") {
            unHeart(row: sender.tag)
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
        }else{
            fillHeart(row: sender.tag)
            sender.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        }
        
    }
    
    func unHeart(row: Int) {
        let newDict = (homeTBArrayChoice[row] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        
        newDict.setValue(0, forKey: "loved")
        
        homeTBArrayChoice.replaceObject(at: row, with: newDict as NSDictionary)
    }
    
    func fillHeart(row: Int) {
        let newDict = (homeTBArrayChoice[row] as! NSDictionary).mutableCopy() as! NSMutableDictionary
        
        newDict.setValue(1, forKey: "loved")
        
        homeTBArrayChoice.replaceObject(at: row, with: newDict as NSDictionary)
    }
    
}

class UIButtonWithDict : UIButton {
    var dict : NSDictionary! = [:]
}
