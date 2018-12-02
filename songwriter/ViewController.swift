//
//  ViewController.swift
//  songwriter
//
//  Created by hellyeah on 12/1/18.
//  Copyright © 2018 hellyeah. All rights reserved.
//

import UIKit
import AVFoundation

struct cellData {
    var opened = Bool()
    var title = String()
    var sectionData = [Int]()
}

class ViewController: UIViewController, AVAudioRecorderDelegate, UITableViewDelegate, UITableViewDataSource {
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    var numberOfRecords:Int = 0
    
    var tableViewData = [cellData]()
    
//    class Highlight: NSObject {
//        var recordNumber: Int!
//        var time: Int!
//
//        init(recordNumber: Int, time: Int) {
//            self.recordNumber = recordNumber
//            self.time = time
//        }
//    }
    
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var highlightLabel: UIButton!
    @IBOutlet weak var timeInRecording: UILabel!
    
    @IBAction func highlight(_ sender: Any) {
        if audioRecorder != nil {
            let currentTime = Int(audioRecorder.currentTime)
            //let currentHighlight = Highlight(recordNumber: numberOfRecords, time: currentTime)
            print(audioRecorder.currentTime)
            //let recordHighlight = NSKeyedArchiver.archivedData(withRootObject: currentHighlight)
            //UserDefaults.standard.setValue(currentTime, forKey: "\(numberOfRecords)")
            
            
            //append value to user defaults
            var nums = UserDefaults.standard.array(forKey: "\(numberOfRecords)") as! [Int]
            nums.append(currentTime)
            UserDefaults.standard.set(nums, forKey: "\(numberOfRecords)")
            
            print(UserDefaults.standard.array(forKey: "\(numberOfRecords)") as! [Int])
        }
    }
    
    @IBAction func record(_ sender: Any) {
        print("pressed record")
        //Check if we have an active recorder
        if audioRecorder == nil {
            numberOfRecords += 1
            UserDefaults.standard.set([Int](), forKey: "\(numberOfRecords)")
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
            print("stopped recording")
            audioRecorder.stop()
            audioRecorder = nil
            
            UserDefaults.standard.setValue(numberOfRecords, forKey: "myNumber")
            //myTableView.append(
            if isKeyPresentInUserDefaults(key: "\(numberOfRecords-1)") {
                let highlights = UserDefaults.standard.array(forKey: "\(numberOfRecords)") as! [Int]
                
                tableViewData.append(cellData(opened: false, title: "Memo \(numberOfRecords-1)", sectionData: highlights))
                myTableView.reloadData()
            } else {
                tableViewData.append(cellData(opened: false, title: "Memo \(numberOfRecords-1)", sectionData: []))
                myTableView.reloadData()
            }
            
            buttonLabel.setTitle("Start Recording", for: .normal)
            
        }
        
    }
    
//
//    func resetDefaults() {
//        let defaults = UserDefaults.standard
//        let dictionary = defaults.dictionaryRepresentation()
//        dictionary.keys.forEach { key in
//            defaults.removeObject(forKey: key)
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        resetDefaults()
        // Do any additional setup after loading the view, typically from a nib.
        
        //later on we'll for loop iterate through user defaults to fill this information in
        tableViewData = []
        
        
    
        //Setting up Session
        recordingSession = AVAudioSession.sharedInstance()
        
        //do we have something in our user defaults. if so, then set the value of numberofrecords to current value in storage
        if let number:Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
            numberOfRecords = number
            print("number of records:\(numberOfRecords)")
            //let records = UserDefaults.standard.array(forKey: "\(numberOfRecords)") as! [Int]
            
            for i in 0..<numberOfRecords {
                print(i)
                if isKeyPresentInUserDefaults(key: "\(i)") {
                    let highlights = UserDefaults.standard.array(forKey: "\(i)") as! [Int]
                    print(highlights)
                    if i < tableViewData.count {
                        tableViewData[i] = cellData(opened: false, title: "Memo \(i)", sectionData: highlights)
                    } else {
                        tableViewData.append(cellData(opened: false, title: "Memo \(i)", sectionData: highlights))
                    }

                } else {
                    if i < tableViewData.count {
                        tableViewData[i] = cellData(opened: false, title: "Memo \(i)", sectionData: [])
                    } else {
                        tableViewData.append(cellData(opened: false, title: "Memo \(i)", sectionData: []))
                    }
                  
                }

                //tableViewData.append(cellData(opened: false, title: "Title1", sectionData: ["cell1", "cell2", "cell3"])
            }
//            for (int i = 0; i < numberOfRecords; i++) {
//                for record in records {
//                    tableViewData.append(record)
//                }
//            }

        }
        
        

        
        
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                print("accepted")
            }
            else {
                
            }
        }
    
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
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
    
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    //Setting up Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        //return numberOfRecords
        return tableViewData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].opened == true {
            return tableViewData[section].sectionData.count + 1
        }
        else {
            return 1
        }
    }
    

    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = String(indexPath.row + 1)
        
        
        let dataIndex = indexPath.row - 1
        
        if indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell()}
            cell.textLabel?.text = tableViewData[indexPath.section].title
            return cell
        }
        else {
            //use different cell identifier if needed
            let (h,m,s) = secondsToHoursMinutesSeconds(seconds:tableViewData[indexPath.section].sectionData[dataIndex])
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell()}
            cell.textLabel?.text = "     Highlight at \(h):\(m):\(s)"
            return cell
        }

        //return cell
    }
    
    // listen to tap on one of the cells to playback

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            if tableViewData[indexPath.section].opened == true {
                tableViewData[indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none) //play around with this
            }
            else {
                tableViewData[indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none) //play around with this
            }
            
            let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: path)
                audioPlayer.play()
                
                if isKeyPresentInUserDefaults(key: "\(indexPath.row+1)") {
                    let highlights = UserDefaults.standard.array(forKey: "\(indexPath.row+1)") as! [Int]
                    print(highlights)
                }
            }
            catch {
                
            }
            
        }
        else {
            let path = getDirectory().appendingPathComponent("\(indexPath.section + 1).m4a")
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: path)
                audioPlayer.play()

                
                if isKeyPresentInUserDefaults(key: "\(indexPath.section+1)") {
                    let highlights = UserDefaults.standard.array(forKey: "\(indexPath.section+1)") as! [Int]
                    print(highlights)
                    print("Index Path: \(indexPath)")
                    let currentHighlight = highlights[indexPath.row-1]
                    //**we'll set current time to the highlight time
                    if currentHighlight > 10 {
                         audioPlayer.currentTime = TimeInterval(currentHighlight-10)
                    } else {
                        audioPlayer.currentTime = TimeInterval(currentHighlight)
                    }
                   
                }
            }
            catch {
                
            }
//**THIS WILL BE WHAT HAPPENS WHEN YOU CLICK ON A HIGHLIGHT
            
            //            let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
//
//            do {
//                audioPlayer = try AVAudioPlayer(contentsOf: path)
//                audioPlayer.play()
//
//                if isKeyPresentInUserDefaults(key: "\(indexPath.row+1)") {
//                    let highlights = UserDefaults.standard.array(forKey: "\(indexPath.row+1)") as! [Int]
//                    print(highlights)
//                }
//            }
//            catch {
//
//            }
            
        }
        

    }
//
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        if tableViewData[indexPath.section].opened == true {
//            tableViewData[indexPath.section].opened = false
//            let sections = IndexSet.init(integer: indexPath.section)
//            tableView.reloadSections(sections, with: .none) //play around with this
//        }
//        else {
//            tableViewData[indexPath.section].opened = true
//            let sections = IndexSet.init(integer: indexPath.section)
//            tableView.reloadSections(sections, with: .none) //play around with this
//        }
//    }
//
}

