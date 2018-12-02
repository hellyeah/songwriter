//
//  ViewController.swift
//  songwriter
//
//  Created by hellyeah on 12/1/18.
//  Copyright © 2018 hellyeah. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!

    var numberOfRecords = 0
    
    @IBOutlet weak var buttonLabel: UIButton!
    @IBAction func record(_ sender: Any) {
        print("pressed record")
        //Check if we have an active recorder
        if audioRecorder == nil {
            numberOfRecords += 1
            let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
        
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 12000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //Start Audio Recording
            do {
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                print("recording")
                buttonLabel.setTitle("Stop Recording", for: .normal)
            }
            catch {
                displayAlert(title: "Oops", message: "Recording failed")
            }
        }
            //case where in this moment we're already recording
        else {
            //Stopping audio recording
            audioRecorder.stop()
            audioRecorder = nil
            print("stopped recording")
            buttonLabel.setTitle("Start Recording", for: .normal)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        //Setting up Session
        recordingSession = AVAudioSession.sharedInstance()
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("accepted")
            }
            else {
                
            }
        }
    
    }

    //Function that gets path to directory (where we'll save audio recordings)
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //Function that displays an alert
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "dismiss", style: .default, handler: nil))
        present(alert, animated:true, completion: nil)
    }
    
    

}

