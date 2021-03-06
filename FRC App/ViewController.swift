//
//  ViewController.swift
//  FRC App
//
//  Created by Michael Miles on 1/22/19.
//  Copyright © 2019 Michael Miles. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView : UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchController : NSFetchedResultsController<Book>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let frc = fetchController {
            return frc.sections!.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sectionInfo = fetchController?.sections?[section] else {
            return "Add Items"
        }
        
        let title = sectionInfo.name
        
        return title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchController.sections?[section].numberOfObjects ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookCell", for: indexPath) as! BookTableViewCell
        
        let entity = fetchController.object(at: indexPath)
        
        cell.bookTitle.text = entity.title ?? "Add Book"
        
        return cell
    }

    @IBAction func addButtonPressed(_ sender: Any) {
        var authorTextField = UITextField()
        var titleTextField = UITextField()
        let alert = UIAlertController(title: "Create New Book", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Book", style: .default) { (action) in
            let newBook = Book(context: self.context)
            
            newBook.title = titleTextField.text
            newBook.author = authorTextField.text
            self.saveData()
            self.loadData()
        }
        alert.addAction(action)
        alert.addTextField { (authTextField) in
            authTextField.placeholder = "New Author Name Here"
            authorTextField = authTextField
        }
        alert.addTextField { (bukTextField) in
            bukTextField.placeholder = "Book Title Here"
            titleTextField = bukTextField
        }
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error Saving Context \(error)")
        }
        tableView.reloadData()
    }
    
    func loadData() {
        let request = NSFetchRequest<Book>(entityName: "Book")
        let sort = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sort]
        fetchController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "author", cacheName: nil)
        
        do {
            try fetchController.performFetch()
        } catch {
            print("Error loading data \(error)")
        }
        tableView.reloadData()
    }
    
}

