//
//  ViewController.swift
//  todo-animations
//
//  Created by Mohamed Dabbour on 12/7/20.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tblNotes: UITableView!
    var notes :[Note]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblNotes.delegate = self
        tblNotes.dataSource = self
        loadData()
        
    }
    @IBAction func addNewNote(_ sender: Any) {
        let alert = UIAlertController(title: "New Note", message: "Enter a title", preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = "Title"
        }
        
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action:UIAlertAction) in
            
            guard let title = alert.textFields?.first?.text else {return}
            let note = Note(title: title, completed: false, createdAt: Date(), id: UUID())
            note.saveItem()
            //Add items with animation
            self.notes.append(note)
            let indexPath = IndexPath(row: self.tblNotes.numberOfRows(inSection: 0), section: 0)
            self.tblNotes.insertRows(at: [indexPath], with: .automatic)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadData(){
        notes = [Note]()
        //Sorted
        notes = DataManager.loadAll(Note.self).sorted(by: {
            $0.createdAt < $1.createdAt
        })
        
        self.tblNotes.reloadData()
    }
}


extension ViewController:NoteCellDelegate{
    
    func didRequestDelete(_ cell: NoteTableViewCell) {
        //Delete with animation
        if let indexPath = tblNotes.indexPath(for: cell) {
            notes[indexPath.row].deleteItem()
            notes.remove(at: indexPath.row)
            tblNotes.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func didRequestComplete(_ cell: NoteTableViewCell) {
        if let indexPath = tblNotes.indexPath(for: cell) {
            notes[indexPath.row].markAsCompleted()
            cell.lblNote.textColor = .green
        }
    }
    
    
}

extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath) as! NoteTableViewCell
        
        cell.delegate = self
        
        let note = notes[indexPath.row]
        
        cell.lblNote.text = note.title
        
        if note.completed {
            cell.lblNote.textColor = .green
        }
        
        return cell
    }
    
    
}

