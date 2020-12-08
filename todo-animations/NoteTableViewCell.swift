//
//  NoteTableViewCell.swift
//  todo-animations
//
//  Created by Mohamed Dabbour on 12/8/20.
//

import UIKit

protocol NoteCellDelegate {
    func didRequestDelete(_ cell:NoteTableViewCell)
    func didRequestComplete(_ cell:NoteTableViewCell)
}

class NoteTableViewCell: UITableViewCell {

    @IBOutlet weak var lblNote: UILabel!
    
    var delegate : NoteCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func completeNote(_ sender: Any) {
        if let delegateObj = self.delegate {
            delegateObj.didRequestComplete(self)
        }
    }
    
    @IBAction func deleteNote(_ sender: Any) {
        if let delegateObj = self.delegate {
            delegateObj.didRequestDelete(self)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
