//
//  ViewController.swift
//  Soundboard
//
//  Created by Alexander Abushady on 7/15/19.
//  Copyright © 2019 Alexander Abushady. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Outlet to the table view.
    @IBOutlet weak var tableView: UITableView!
    
    // Variables for working with Core Data, and playing audio.
    var sounds : [Sound] = []
    var audioPlayer : AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Set delegate and data source within the View Controller.
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // Reload the table view when Core Data is changed.
    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            sounds = try context.fetch(Sound.fetchRequest())
            tableView.reloadData()
        } catch {}
    }
    
    // Set the number of rows in the table view to the amount of entities in Core Data.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sounds.count
    }
    
    // Dictates what is placed within each cell of the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let sound = sounds[indexPath.row]
        cell.textLabel?.text = sound.name
        return cell
    }

    // When selecting a row play audio.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sound = sounds[indexPath.row]
        do {
            audioPlayer = try AVAudioPlayer(data: sound.audio! as Data)
            audioPlayer?.play()
        } catch {}
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Functionality for swiping to delete a Core Data Entity. Also updates the table view with the updated array from Core Data.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let sound = sounds[indexPath.row]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(sound)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do {
                sounds = try context.fetch(Sound.fetchRequest())
                tableView.reloadData()
            } catch {}
        }
    }
}
