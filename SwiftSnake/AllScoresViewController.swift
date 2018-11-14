//
//  AllScoresViewController.swift
//  SwiftSnake
//
//  Created by Ben Bauer on 11/13/18.
//  Copyright © 2018 Weizhong yang. All rights reserved.
//

import UIKit
import CoreData

class AllScoresViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var localScores = [Score]()
    var users = [User]()
    var currentUser = ""
    var globalScores = [NSDictionary]()
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var saveContext = (UIApplication.shared.delegate as! AppDelegate).saveContext
    
    @IBOutlet weak var userScoresTable: UITableView!
    
    @IBOutlet weak var globalScoresTable: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
            case userScoresTable:
                if localScores.count > 5 {
                return 5
                }
                else {
                    return localScores.count
                }
            case globalScoresTable:
                if globalScores.count > 5 {
                    return 5
                }
                else {
                    return globalScores.count
                }
            default:
                print("yo mama")
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        switch tableView {
        case userScoresTable:
            cell = tableView.dequeueReusableCell(withIdentifier: "userScoreCell", for: indexPath)
            cell.textLabel?.text = String("\(currentUser) \(localScores[indexPath.row].score)")
        case globalScoresTable:
            cell = tableView.dequeueReusableCell(withIdentifier: "globalScoreCell", for: indexPath)
            cell.textLabel?.text = String(String(globalScores[indexPath.row]["userName"] as! String))
            cell.detailTextLabel?.text = String(globalScores[indexPath.row]["score"] as! Int)
        default:
            print("Something fucked up")
        }
        cell.textLabel?.textColor = UIColor(red: 0.7, green: 1, blue: 0.44, alpha: 1)
        cell.detailTextLabel?.textColor = UIColor(red: 0.7, green: 1, blue: 0.44, alpha: 1)
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        userScoresTable.dataSource = self
        userScoresTable.delegate = self
        globalScoresTable.dataSource = self
        globalScoresTable.delegate = self
        userScoresTable.isScrollEnabled = true
        globalScoresTable.isScrollEnabled = true
        
        let request : NSFetchRequest<Score> = Score.fetchRequest()
        let scoreSort = NSSortDescriptor(key: "score", ascending: false)
        
        
        request.sortDescriptors = [scoreSort]
        do {
            let result = try context.fetch(request)
            localScores = result
            
        }
        catch {
            print("\(error)")
        }
        
        let nameRequest = NSFetchRequest<NSFetchRequestResult>(entityName : "User")
        do {
            let result = try context.fetch(nameRequest)
            users = result as! [User]
            print(users)
            currentUser = users[0].name!
            print(currentUser)
        }
        catch {
            print("\(error)")
        }
        
        ScoreModel.getAllScores() {
            data, response, error in
            do {
                if let scores = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary] {
                    self.globalScores = scores
                    DispatchQueue.main.async {
                        self.globalScoresTable.reloadData()
                    }
                }
            } catch {
                print("Something went wrong")
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

