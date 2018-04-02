// 
// Copyright (c) 2018年, htamakos.
// All rights reserved.
//


import UIKit

class ViewController: UITableViewController {
    private var todoItems = [ToDoItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "To-Do"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.didTapAddItemButton(_:)))
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UIApplicationDelegate.applicationDidEnterBackground(_:)),
                                               name: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil)
        
        do {
            self.todoItems = try [ToDoItem].readFromPersistence()
        } catch let error as NSError {
            if error.domain == NSCocoaErrorDomain && error.code == NSFileReadNoSuchFileError {
                NSLog("No persistence file found, not necesserially an error...")
            } else {
                let alert = UIAlertController(title: "Error", message: "Cloud not load the to-do items", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                
                NSLog("Error loading from persistence: ¥(error)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_todo", for: indexPath)
        
        if indexPath.row < todoItems.count {
            let item = todoItems[indexPath.row]
            cell.textLabel?.text = item.title
            
            let accessory: UITableViewCellAccessoryType = item.done ? .checkmark : .none
            cell.accessoryType = accessory
        }
        
        return cell
    
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < todoItems.count {
            let item = todoItems[indexPath.row]
            item.done = !item.done
            
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    @objc func didTapAddItemButton(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New to-do item", message: "Insert the title of the new to-do item:", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            if let title = alert.textFields?[0].text {
                self.addNewToDoItem(title: title)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func addNewToDoItem(title: String) {
        let newIndex = todoItems.count
        
        todoItems.append(ToDoItem(title: title))
        
        tableView.insertRows(at: [IndexPath(row: newIndex, section: 0)], with: .top)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.row < todoItems.count {
            todoItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .top)
        }
    }
    
    @objc public func applicationDidEnterBackground(_ notification: NSNotification) {
        do {
            try todoItems.writeToPersistence()
        } catch let error as NSError {
            NSLog("Error writing to persistencve: ", error)
        }
    }

}

