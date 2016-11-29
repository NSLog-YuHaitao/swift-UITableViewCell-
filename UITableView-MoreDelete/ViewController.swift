//
//  ViewController.swift
//  UITableView-MoreDelete
//
//  Created by 于海涛 on 16/6/15.
//  Copyright © 2016年 于海涛. All rights reserved.

/*
 注释:
 cellArr:数组用来删除动画效果
 */

import UIKit


class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    //所谓的宏定义,不带参数
    let width = UIScreen.mainScreen().bounds.size.width
    let height = UIScreen.mainScreen().bounds.size.height
    //带参数宏定义其实就是方法
    func MakeColor(r : CGFloat, g : CGFloat , b : CGFloat) -> UIColor {
        return UIColor.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    

    //<1>属性
    //UITabelView
    var tableView : UITableView!
    //数据源
    var dataArr : NSMutableArray!
    
    //右按钮
    var allBtn : UIBarButtonItem!
    var deleteBtn : UIBarButtonItem!
    
    //待删除的数据的数组
    var deleteArr : NSMutableArray!
    //待删除的cell的数组
    var cellArr : NSMutableArray!
    
    //用来记录全选按钮的点击状态:是否执行全选操作,还是全不选操作
    var isAll : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = MakeColor(0.8, g: 0.4, b: 0.5)
        
        //<1>.创建数据源
        self.createDataArray()
        //<2>.创建UITabelView
        self.createTabelView()
        //<3>.创建左右按钮
        self.createButton()
    
    }
        
    
    //MARK: -  创建数据源
    func createDataArray() -> Void{
        dataArr = NSMutableArray.init(capacity: 0)
        deleteArr = NSMutableArray.init(capacity: 0)
        cellArr = NSMutableArray.init(capacity: 0)
        
        for i in 1...30 {
            dataArr.addObject("这是第\(i)条数据")
        }
        
    }
    
    //MARK: -  创建UITableView
    func createTabelView() -> Void{
        self.tableView = UITableView.init(frame: CGRectMake(0, 64, width, height-64), style: UITableViewStyle.Plain)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //注册cell
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "CellID")
        
        self.view .addSubview(self.tableView)
        
    }
    
    //MARK: -  创建左右按钮
    func createButton() -> Void{
        //左按钮:编辑按钮
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        //右按钮:删除按钮
        self.deleteBtn = UIBarButtonItem.init(title: "删除", style: UIBarButtonItemStyle.Done, target: self, action: #selector(ViewController.deletBtnClick))
        
        //全选按钮的创建
        self.allBtn = UIBarButtonItem.init(title: "全选", style: UIBarButtonItemStyle.Done, target: self, action:#selector(ViewController.allBtnClick))
    }
    //MARK: - 编辑删除对应的方法
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        //参数:editing默认是false
        //判断editing的状态
        if editing {
            self.navigationItem.rightBarButtonItems = [self.deleteBtn,self.allBtn]
        }else{
            self.navigationItem.rightBarButtonItems = nil
        }
        
        //⚠️:解决问题2
        //将deleteArr和cellArr清空
        self.deleteArr.removeAllObjects()
        self.cellArr.removeAllObjects()
        self.isAll = false
        
        //设置tableView的编辑状态
        //self.tableView.editing 能获取到tableView的编辑状态,默认false
        self.tableView.setEditing(!self.tableView.editing, animated: true)
        //或者
//        self.tableView.setEditing(editing, animated: true)
    }
    
    //MARK: - 一键删除对应的方法
    func deletBtnClick() -> Void {
        
        //将deleteArr里面的数据从dataArr里面删除
        dataArr.removeObjectsInArray(self.deleteArr as [AnyObject])
        
        //带有动画效果的删除
        self.tableView.deleteRowsAtIndexPaths(self.cellArr as NSArray as! Array, withRowAnimation: UITableViewRowAnimation.Automatic)
        
        self.tableView.reloadData()
        
        //⚠️解决问题3:清空deleteArr和cellArr
        self.deleteArr.removeAllObjects()
        self.cellArr.removeAllObjects()
        
    }
    //MARK: - 全选按钮对应的方法
    func allBtnClick() -> Void {
        
        //将状态置反
        self.isAll = !self.isAll
        
        if isAll {
            //全选
            //遍历数据源的个数
            for row in 0..<dataArr.count {
                //获取所有cell的下标
                let indexPath = NSIndexPath.init(forRow: row, inSection: 0)
                
                //将所有的cell选中
                self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
                
                //将cell的下标放到cellArr里面
                self.cellArr.addObject(indexPath)
            }
            //将dataArr里面的所有数据放到deleteArr里面
            self.deleteArr.addObjectsFromArray(self.dataArr as [AnyObject])
        
        }else{
            
             //全不选
            for row in 0..<self.dataArr.count {
                //取消选中
                //获取所有cell的下标
                let indexPath = NSIndexPath.init(forRow: row, inSection: 0)
                self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
            
            //将数组清空
            self.cellArr.removeAllObjects()
            self.deleteArr.removeAllObjects()
        }
    }
    

    
    //MARK: -  代理方法
    //设置tableView的行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
     
        return dataArr.count
    }
    
    //设置UITableViewCell
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath:indexPath)
        
        cell.textLabel?.text = self.dataArr[indexPath.row] as? String
        
        return cell
    }
    
    //MARK: -  多选删除相关的代理方法
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle{
        
        return UITableViewCellEditingStyle.init(rawValue: UITableViewCellEditingStyle.Delete.rawValue|UITableViewCellEditingStyle.Insert.rawValue)!
    }
    
    //MARK: - 选中那一行的选中事件,把数据存放到deleteArr数组中
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //⚠️:前提:必须在编辑状态的前提下才可以存储到deleteArr数组中
        if self.tableView.editing {
            //编辑状态
            self.deleteArr.addObject(self.dataArr[indexPath.row])
            
            //删除cell的动画效果
            //将选中的cell放到数组里,存放cellArr
            //indexPath存在section和row
            self.cellArr.addObject(indexPath)
            
        }else{
            //不可编辑状态
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }
    }
    
    //MARK: - 取消选中,取消的数据从deleteArr里面删除
    //⚠️:解决问题1
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        if self.tableView.editing {
            
            //将取消选中的数据从deleteArr里面删除
            self.deleteArr.removeObject(self.dataArr[indexPath.row])
            
            //将取消选中的移除cellArr数组
            self.cellArr.removeObject(indexPath)
            
            self.isAll = false
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

