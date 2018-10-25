//
//  ImageViewController.swift
//  NeCTARClient
//
//  Created by XuMiao on 17/4/10.
//  Copyright © 2017年 Xinrui Xu. All rights reserved.
//

import UIKit
import MBProgressHUD

class ImageViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableview: UITableView!
    var refreshControl: UIRefreshControl!
    // this view controller is  not used in this version
    var hudParentView = UIView()
    
    var editImageViewController: EditImageViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hudParentView = self.view
        MBProgressHUD.showHUDAddedTo(hudParentView, animated: true)

        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(ImageViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableview.addSubview(refreshControl)
        commonInit()
        
            self.tableview.contentInset = UIEdgeInsetsMake(0, 0, 60, 0);
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        //self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    func commonInit() {
        if let user = UserService.sharedService.user{
            let url = user.imageServiceURL + "v2/images"
            let token = user.tokenID
            let owner = "28eadf5ad64b42a4929b2fb7df99275c"
            let selfOwner = user.owner
            NeCTAREngine.sharedEngine.listImages(url, token: token, owner: selfOwner).then{ (json) -> Void in
                let images = json["images"].arrayValue
                ImageService.sharedService.clear()
                print(json)
                for image in images {
                    
                    let instance = Image(json: image)
                    ImageService.sharedService.images.append(instance!)
                    
                    self.tableview.reloadData()
                    self.refreshControl.endRefreshing()
                    MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                }
                }.error{(err) -> Void in
                    var errorMessage:String = "Action Failed."
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg!
                    case NeCTAREngineError.ErrorStatusCode(let code):
                        if code == 401 {
                            loginRequired()
                        }  else {
                            errorMessage = "Fail to get images"
                        }
                    default:
                        errorMessage = "Fail to get images"
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }
            
            NeCTAREngine.sharedEngine.listImages(url, token: token, owner: owner).then{ (json) -> Void in
                let images = json["images"].arrayValue
                //ImageService.sharedService.clear()
                print(json)
                for image in images {
                    
                    let instance = Image(json: image)
                    ImageService.sharedService.images.append(instance!)
                    
                    self.tableview.reloadData()
                    self.refreshControl.endRefreshing()
                    MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                }
                }.error{(err) -> Void in
                    var errorMessage:String = "Action Failed."
                    switch err {
                    case NeCTAREngineError.CommonError(let msg):
                        errorMessage = msg!
                    case NeCTAREngineError.ErrorStatusCode(let code):
                        if code == 401 {
                            loginRequired()
                        } else {
                            errorMessage = "Fail to get images"
                        }
                    default:
                        errorMessage = "Fail to get images"
                    }
                    PromptErrorMessage(errorMessage, viewController: self)
            }

            
        }

    }
    
    
    func refresh(sender:AnyObject) {
        // Code to refresh table view
        commonInit()
    }


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ImageService.sharedService.images.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if ImageService.sharedService.images.count != 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("ImageDetail") as! ImageDetailCell
            cell.setContent(indexPath.row)
            return cell
        }
        // Configure the cell...

        return UITableViewCell()
    }
    
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let delete = UITableViewRowAction(style: .Normal, title: "Delete") {
            action, index in
            
            print("delete")
            
            let alertController = UIAlertController(title: "Confirm Delete image", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                (action: UIAlertAction!) -> Void in
                self.dismissViewControllerAnimated(false, completion: nil)
            })
            let okAction = UIAlertAction(title: "Delete", style: UIAlertActionStyle.Destructive, handler: {
                (action: UIAlertAction!) -> Void in

            
            if let user = UserService.sharedService.user {
                let url = user.imageServiceURL
                let imageId = ImageService.sharedService.images[indexPath.row].id
                
                print(user.owner)
                print(ImageService.sharedService.images[indexPath.row].owner)
                
                if user.owner == ImageService.sharedService.images[indexPath.row].owner {
                    
                    print("delete")
                    
                    MBProgressHUD.showHUDAddedTo(self.hudParentView, animated: true)
                    NeCTAREngine.sharedEngine.deleteImage(url, token: user.tokenID, imageId: imageId).then {
                        (json) -> Void in
                        print("delete")
                        print (json)
                        let msg = "Please refresh."
                        let alert = UIAlertController(title: "Delete Success", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        }.always{
                            MBProgressHUD.hideHUDForView(self.hudParentView, animated: true)
                        }.error{ (err) -> Void in
                            print(err)
                            var errorMessage:String = "Action Failed."
                            switch err {
                            case NeCTAREngineError.CommonError(let msg):
                                errorMessage = msg!

                            case NeCTAREngineError.ErrorStatusCode(let code):
                                if code == 401 {
                                    loginRequired()
                                } else {
                                    errorMessage = "Action failed."
                                }
                            default:
                                errorMessage = "Action failed."
                            }
                            PromptErrorMessage(errorMessage, viewController: self)
                    }
                    
                } else {
                    let msg = "You can not delete this image."
                    let alert = UIAlertController(title: "Error", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    }))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            })
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        delete.backgroundColor = UIColor.redColor()
        
//        let edit = UITableViewRowAction(style: .Normal, title: "Edit") {
//            action, index in
//            
//            
//            
//            if let user = UserService.sharedService.user {
//                
//                print(user.owner)
//                print(ImageService.sharedService.images[indexPath.row].owner)
//                
//                if user.owner == ImageService.sharedService.images[indexPath.row].owner {
//                    
//                    self.editImageViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EditImageViewController") as! EditImageViewController
//                    //self.navigationItem.title = "New Instance"
//                    //self.navigationItem.rightBarButtonItem = nil
//                    
//                    self.navigationController?.pushViewController(self.editImageViewController, animated: true)
//                    self.editImageViewController.name = ImageService.sharedService.images[indexPath.row].name
//                    self.editImageViewController.id = ImageService.sharedService.images[indexPath.row].id
//                    self.editImageViewController.disk = ImageService.sharedService.images[indexPath.row].disk
//                    self.editImageViewController.ram = ImageService.sharedService.images[indexPath.row].ram
//                    self.editImageViewController.isPublic = ImageService.sharedService.images[indexPath.row].isPublic
//                    self.editImageViewController.isProtected = ImageService.sharedService.images[indexPath.row].isProtected
//                    self.editImageViewController.format = ImageService.sharedService.images[indexPath.row].format
//                    
//                    
//                } else {
//                    let msg = "You can not edit this image."
//                    let alert = UIAlertController(title: " Error", message: msg, preferredStyle: UIAlertControllerStyle.Alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { Void in
//                        self.dismissViewControllerAnimated(false, completion: nil)
//                    }))
//                    self.presentViewController(alert, animated: true, completion: nil)
//                }
//            }
//            
//            
//        }
//        edit.backgroundColor = UIColor.orangeColor()
        
        return [delete]
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowImageDetail" {
            let cell = sender as! ImageDetailCell
            let path = self.tableview.indexPathForCell(cell)
            let detailVC = segue.destinationViewController as! ImageDetailViewController
            detailVC.navigationItem.title = "Image Detail"
            detailVC.image = ImageService.sharedService.images[(path?.row)!]
            detailVC.index = path?.row
            
        }
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
