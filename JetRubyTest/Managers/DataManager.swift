//
//  DataManager.swift
//  JetRubyTest
//
//  Created by Andrey Snetkov on 21/02/2018.
//  Copyright © 2018 Andrey Snetkov. All rights reserved.
//

import Foundation
import RealmSwift

class DataManager: NSObject {
    
    static let shared: DataManager = {
        let instance = DataManager()
        return instance
    }()
    
    private var currentPage = 0
    private var currentSortIndex = 0
    private var loadCompletion:(([DribbleShotViewModel])->Void)?
    
    private var completionId: String?
    
    func getShots(completion: @escaping ([DribbleShotViewModel])->Void) {
        completionId = UUID().uuidString
        currentPage = 0
        currentSortIndex = 0
        loadCompletion = completion
        self.sendCurrentShots()
        loadNextPage()
    }
    
    private func loadNextPage() {
        let currentCompletionId = completionId
        APIManager.loadShots(page: currentPage, completion: {result in
            
            if(currentCompletionId! != self.completionId!) {
                return
            }
            if let shots = result as? [[String: Any]] {
                self.saveValues(shots: shots)
            }
            else if let message = result as? String {
                NotificationCenter.default.post(name: Notification.Name(LOAD_FAILED_NOTIFICATION), object: message)
            }
        })
    }
    
    private func saveValues(shots: [[String: Any]]) {
        DispatchQueue.global(qos: .background).async {
            
            let database = try! Realm()
            for i in 0..<shots.count {
                let shotDict = shots[i]
                if let identity = shotDict["id"] as? Int {
                    if(shotDict["animated"] as? Int == 1) {
                        continue
                    }
                    if let shot = database.object(ofType: DribbleShot.self, forPrimaryKey: identity) {
                        try! database.write {
                            shot.updateValuesFrom(dict: shotDict)
                            shot.sortIndex = self.currentSortIndex
                        }
                    }
                    else {
                        let shot = DribbleShot()
                        shot.fillValuesFrom(dict: shotDict)
                        try! database.write {
                            database.add(shot)
                            shot.sortIndex = self.currentSortIndex
                        }
                    }
                    self.currentSortIndex += 1
                    
                }
            }
            
            self.sendCurrentShots()
            let allShots = database.objects(DribbleShot.self)
            if(allShots.count < 50) {
                DispatchQueue.main.async {
                    self.currentPage += 1
                    self.loadNextPage()
                }
            }
        }
    }
    
    private func sendCurrentShots() {
        DispatchQueue.global(qos: .background).async {
            
            let database = try! Realm()
            let allShots = database.objects(DribbleShot.self).sorted(by: {$0.sortIndex < $1.sortIndex})
            var shotViewModels = [DribbleShotViewModel]()
            for i in 0..<allShots.count {
                let shot = allShots[i]
                if(i >= 50) {
                    try! database.write {
                        database.delete(shot)
                    }
                    continue
                }
                
                let shotViewModel = DribbleShotViewModel()
                shotViewModel.fillFromDataModel(shot: shot)
                shotViewModels.append(shotViewModel)
            }
            
            DispatchQueue.main.async {
                self.loadCompletion!(shotViewModels)
            }
        }
    }
    
    
}
