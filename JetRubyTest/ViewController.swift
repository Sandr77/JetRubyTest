//
//  ViewController.swift
//  JetRubyTest
//
//  Created by Andrey Snetkov on 20/02/2018.
//  Copyright © 2018 Andrey Snetkov. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView?
    
    var shots = [DribbleShotViewModel]()
    
    private let refreshControl = UIRefreshControl()

    private var heightAtIndexPath = [Int: CGFloat]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 10.0, *) {
            tableView!.refreshControl = refreshControl
        } else {
            tableView!.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(reloadShots), for: .valueChanged)
        tableView?.register(UINib.init(nibName: "ShotsListTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ShotsListTableViewCellId")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(loadFailedNotification(notification:)), name: Notification.Name(LOAD_FAILED_NOTIFICATION), object: nil)
        
        DataManager.shared.getShots(completion: { result in
            self.shots = result
            self.tableView?.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func loadFailedNotification(notification: Notification) {
        self.refreshControl.endRefreshing()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            let message = notification.object as! String
            let alert = UIAlertController.init(title: "Error", message: message, preferredStyle: .alert)
            let action = UIAlertAction.init(title: "OK", style: .default, handler: {action in
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        })
       
    }
    
    @objc func reloadShots() {
        DataManager.shared.getShots(completion: { result in
            self.refreshControl.endRefreshing()
            self.shots = result
            self.tableView?.reloadData()
        })
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shots.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShotsListTableViewCellId") as! ShotsListTableViewCell
        cell.shot = shots[indexPath.row]
        cell.fillValues()
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = shots[indexPath.row]
        let height = heightAtIndexPath[item.identity]
        if ((height) != nil) {
            return height!
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = shots[indexPath.row]
        heightAtIndexPath[item.identity] = cell.frame.size.height
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        NotificationCenter.default.post(name: Notification.Name(ORIENTATION_CHANGED_NOTIFICATION), object: nil)
        self.tableView?.layoutIfNeeded()
    }

}

