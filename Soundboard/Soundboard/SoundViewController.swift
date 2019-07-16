//
//  SoundViewController.swift
//  Soundboard
//
//  Created by Alexander Abushady on 7/16/19.
//  Copyright © 2019 Alexander Abushady. All rights reserved.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    // Setting outlets for each input field.
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    // Variables for recording, playing, and storing audio.
    var audioRecorder : AVAudioRecorder?
    var audioPlayer : AVAudioPlayer?
    var audioURL : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Sets up the audio recorder and makes sure that the appropriate buttons are disabled.
        setupRecorder()
        playButton.isEnabled = false
        addButton.isEnabled = false
    }
    
    // Adds functionality to record audio.
    func setupRecorder() {
        do {
            // Create an audio session.
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord)
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            // Create URL for the audio file.
            let basePath : String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            // Create settings for the audio recorder.
            var settings : [String:AnyObject] = [:]
            settings[AVFormatIDKey] = kAudioFormatMPEG4AAC as AnyObject
            settings[AVSampleRateKey] = 44100.0 as AnyObject
            settings[AVNumberOfChannelsKey] = 2 as AnyObject
            
            // Create AudioRecorder object
            audioRecorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            print(error)
        }
    }
    
    // Record audio from microphone when record is tapped.
    @IBAction func recordTapped(_ sender: Any) {
        if audioRecorder!.isRecording {
            // Stop the recording.
            audioRecorder?.stop()
            
            // Change button title to record.
            recordButton.setTitle("Record", for: .normal)
            
            // Enable appropriate buttons.
            playButton.isEnabled = true
            addButton.isEnabled = true
        } else {
            // Start the recording.
            audioRecorder?.record()
            // Change button title to stop.
            recordButton.setTitle("Stop", for: .normal)
            
            // Disable appropriate buttons.
            playButton.isEnabled = false
            addButton.isEnabled = false
        }
    }
    
    // Play audio when play is tapped.
    @IBAction func playTapped(_ sender: Any) {
        do {
            // Pulls the audio from the audioURL to play it.
            try audioPlayer = AVAudioPlayer(contentsOf: audioURL!)
            audioPlayer!.play()
        } catch {}
    }
    
    // When add is tapped the audio is then sent to Core Data.
    @IBAction func addTapped(_ sender: Any) {
        // Connect to Core Data.
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        // Allows for creation of a Sound Entity.
        let sound = Sound(context: context)
        
        // Create a Sound Entitiy.
        sound.name = nameTextField.text
        sound.audio = NSData(contentsOf: audioURL!) as Data?
        
        // Update Core Data with the new Sound entity.
        (UIApplication.shared.delegate as! AppDelegate).saveContext()

        // After adding to Core Data return to the main view controller.
        navigationController!.popViewController(animated: true)
    }
}
