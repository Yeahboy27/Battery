//
//  ELLViewController.swift
//  Battery test 3
//
//  Created by MAC on 5/8/17.
//  Copyright © 2017 example.com. All rights reserved.
//

import UIKit


class ELLViewController: UIViewController {
    var root: ELLIOKitNodeInfo?
    var locationInTree: ELLIOKitNodeInfo?
    
    @IBOutlet weak var trailLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var searchTerm: NSString = ""
    var trailStack: NSMutableArray?
    var offsetStack: NSMutableArray?
    var dumper: ELLIOKitDumper?
    let kSearchTerm: NSString = "kSearchTerm"
    
    override func awakeFromNib() {
        self.dumper = ELLIOKitDumper()
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self._loadIOKit()
    }
    
    func _loadIOKit() {
        tableView.isHidden = true
        self.trailStack = NSMutableArray()
        self.offsetStack = NSMutableArray()
        DispatchQueue.main.async {
            self.root = self.dumper?.dumpIOKitTree()
            self.locationInTree = self.root
            
            DispatchQueue.main.async {
                self.trailStack?.add(self.root?.name)
                self._setupTrail()
                self.tableView.reloadData()
                self.tableView.isHidden = false
                for child  in (self.locationInTree?.children)! {
                    if let _child = child as? ELLIOKitNodeInfo {
                        print(_child.name)
                        print(_child.properties)
                    }
                }
            }
        }
    }
    
    func _setupTrail() {
        trailLabel.attributedText = self._stringForTrail(stack: trailStack!)
    }
    
    func _stringForTrail(stack: NSArray) ->  NSAttributedString {
        return NSAttributedString(string: stack.componentsJoined(by: " > "))
    }
    
    func propertiesForLocation() -> NSArray {
        if(locationInTree == nil) {
           return NSArray()
        }
        if(searchTerm.length == 0) {
            return (locationInTree?.properties)! as NSArray
        } else {
            return (locationInTree?.matchingProperties)! as NSArray
        }
    }
    
    func childrenForLocation() -> NSArray {
        if(locationInTree == nil) {
            return NSArray()
        }
        if(searchTerm.length == 0) {
            return (locationInTree?.children)!
        } else {
            return (locationInTree?.matchedChildren)! as NSArray
        }
    }
    
    func highlightSearchTerm(seacrchTerm: NSString, text: NSMutableAttributedString) {
        if(seacrchTerm.length > 0) {
            var attrs: NSDictionary = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14.0)]
            var range: NSRange = (text.string as NSString).range(of: seacrchTerm as String, options: .caseInsensitive)
            while range.location != NSNotFound {
                text.setAttributes(attrs as! [String : Any], range: range)
                range = (text.string as NSString).range(of: searchTerm as! String, options: .caseInsensitive, range: NSMakeRange(range.location + 1,text.length - range.location - 1))
            }
            
        }
    }
    

}

extension ELLViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return self.propertiesForLocation().count
        } else {
            return self.childrenForLocation().count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0) {
            return (propertiesForLocation().count > 0) ? "Properties" : ""
        } else {
            return (childrenForLocation().count > 0) ? "Children" : ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indetifier: String = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: indetifier, for: indexPath)
        var cellText: NSString = ""
        if(indexPath.section == 0) {
            cellText = self.propertiesForLocation()[indexPath.row] as! NSString
            cell.accessoryType = .none
        } else {
            var childNode: ELLIOKitNodeInfo = self.childrenForLocation()[indexPath.row] as! ELLIOKitNodeInfo
            cellText = "\(childNode.name)" + "\(childNode.searchCount)" as NSString
            cell.accessoryType = .disclosureIndicator
        }
        var text: NSMutableAttributedString = NSMutableAttributedString(string: cellText as String)
        self.highlightSearchTerm(seacrchTerm: searchTerm, text: text)
        cell.textLabel?.attributedText = text
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == 1) {
            let childNode: ELLIOKitNodeInfo = self.childrenForLocation()[indexPath.row] as! ELLIOKitNodeInfo
            self.locationInTree = childNode
            trailStack?.add(locationInTree?.name)
            offsetStack?.add(NSValue.init(cgPoint: tableView.contentOffset))
            tableView.contentOffset = CGPoint.zero
            self._setupTrail()
            tableView.reloadData()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}





























