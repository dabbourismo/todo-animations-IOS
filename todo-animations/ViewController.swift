//
//  ViewController.swift
//  todo-animations
//
//  Created by Mohamed Dabbour on 12/7/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let notes = Note(title: "Defeat Thanos", completed: false, createdAt: Date(), id: UUID())
        
        let items = DataManager.loadAll(Note.self)
        print(items)
    }


}

