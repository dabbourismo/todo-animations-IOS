//
//  ContainerViewController.swift
//  todo-animations
//
//  Created by Mohamed Dabbour on 12/9/20.
//

import UIKit

class ContainerViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var connectionButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    var noteTableViewController : ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Circular button
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerTOviewController" {
            noteTableViewController = (segue.destination as! UINavigationController)
                .children.first as! ViewController
            noteTableViewController.connectionButtonReference = connectionButton
        }
    }
    
    @IBAction func addNewNote(_ sender: Any) {
        noteTableViewController.addNewNote(sender)
    }
    
    @IBAction func triggerConnection(_ sender: Any) {
        noteTableViewController.showConnectivityAction(sender)
    }
    
}
