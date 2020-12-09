//
//  ViewController.swift
//  todo-animations
//
//  Created by Mohamed Dabbour on 12/7/20.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {
    
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var tblNotes: UITableView!
    var notes :[Note]!{
        didSet{
            progressBar.setProgress(progress, animated: true)
        }
    }
    var peerId:MCPeerID!
    var mcSession:MCSession!
    var mcAdvertiserAssistant:MCAdvertiserAssistant!
    var connectionButtonReference:UIButton!
    var progress:Float{
        if notes.count>0 {
            return Float(notes.filter({$0.completed}).count) / Float(notes.count)
        }else{
            return 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblNotes.delegate = self
        tblNotes.dataSource = self
        setUpConnectivity()
        loadData()
        
    }
    @IBAction func showConnectivityAction(_ sender: Any) {
        let actionSheet = UIAlertController(title: "Exchange", message: "Do you want to host or join a session?", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Host Session", style: .default, handler: { (action:UIAlertAction) in
            self.mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "Note-Todo", discoveryInfo: nil, session: self.mcSession)
            self.mcAdvertiserAssistant.start()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Join Session", style: .default, handler: { (action:UIAlertAction) in
            let mcBrowser = MCBrowserViewController(serviceType: "Note-ToDo", session: self.mcSession)
            mcBrowser.delegate = self
            self.present(mcBrowser, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
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
    
    func setUpConnectivity(){
        peerId = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    func loadData(){
        notes = [Note]()
        //Sorted
        notes = DataManager.loadAll(Note.self).sorted(by: {
            $0.createdAt < $1.createdAt
        })
        
        self.tblNotes.reloadData()
        progressBar.setProgress(progress, animated: true)
    }
}
//MARK:-MCDelegates

extension ViewController:MCSessionDelegate,MCBrowserViewControllerDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected \(peerID.displayName)")
            DispatchQueue.main.async {
                self.connectionButtonReference.setTitle("Connected", for: .normal)
            }
            
        case MCSessionState.connecting:
            print("Connecting \(peerID.displayName)")
            self.connectionButtonReference.setTitle("Connecting...", for: .normal)
            
        case MCSessionState.notConnected:
            print("Not-Connected \(peerID.displayName)")
            self.connectionButtonReference.setTitle("Offline", for: .normal)
        default:
            fatalError()
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        let note = try! JSONDecoder().decode(Note.self, from: data)
        DataManager.save(note, with: note.id.uuidString)
        DispatchQueue.main.async {
            self.loadData()
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
    
//MARK:-Note Cell Delegate
extension ViewController:NoteCellDelegate{

    func sendNote(_ note:Note){
        if mcSession.connectedPeers.count > 0 {
            if let note = DataManager.loadData(note.id.uuidString) {
                try! mcSession.send(note, toPeers: mcSession.connectedPeers, with: .reliable)
            }
        }else{
            showConnectivityAction(self)
        }
    }
    
    func didRequestShare(_ cell: NoteTableViewCell) {
        if let indexPath = tblNotes.indexPath(for: cell) {
        let note = notes[indexPath.row]
            sendNote(note)
        }
    }
    
    
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
            UIView.animate(withDuration: 0.1) {
                cell.transform = cell.transform.scaledBy(x: 1.1, y: 1.1)
            } completion: { (success:Bool) in
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut) {
                    cell.transform = CGAffineTransform.identity
                } completion: { (success:Bool) in
                    print("Animated")
                }
                
            }
            
        }
    }
    
    
}
//MARK:-TableViewDelegate
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

