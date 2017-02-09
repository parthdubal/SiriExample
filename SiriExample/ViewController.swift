//
//  ViewController.swift
//  PassDemo
//
//  Created by Parth Dubal on 12/21/16.
//  Copyright © 2016 Parth Dubal. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices
import Speech

let KEY = "times";

@available(iOS 10.0, *)
class ViewController: UIViewController,SFSpeechRecognizerDelegate,ObjcFileProtocol {
    
    @IBOutlet weak var lblButton: UIButton!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var lblSpeechValue: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-IN"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        print("SFSpeechRecognizer.supportedLocales()>>> \(SFSpeechRecognizer.supportedLocales())");
        
        lblSpeechValue.numberOfLines = 0;
        lblSpeechValue.lineBreakMode = .byWordWrapping;
        lblSpeechValue.textAlignment = .center;
        
        // Do any additional setup after loading the view, typically from a nib.
        let appOpen = NSUserActivity(activityType: "app.open.times");
        
        appOpen.isEligibleForSearch = true;
        appOpen.isEligibleForPublicIndexing = true;
        appOpen.isEligibleForHandoff = true;
        
        appOpen.title = "App open times";
        appOpen.needsSave = true;
        appOpen.keywords = ["app open","open times","times","open","passtime","siri counter"];
        var times = UserDefaults.standard.integer(forKey: KEY);
        times += 1;
        appOpen.userInfo = ["times":times];
        UserDefaults.standard.set(times, forKey: KEY);
        
        //        userActivity = appOpen;
        let sets = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String);
        sets.authorNames = ["app times","open times"];
        sets.contentDescription = "tells you app open updates";
        sets.thumbnailData = UIImageJPEGRepresentation(UIImage(named: "AppIcon60x60")!, 1.0);
        sets.supportsPhoneCall = true
        
        sets.phoneNumbers = ["9016784512"]
        sets.emailAddresses = ["WOW@OW.COM"]
        sets.keywords = ["app open","open times","times","open","passtime","siri counter"]
        appOpen.contentAttributeSet = sets
        
        
        
        let appOpen1 = NSUserActivity(activityType: "app.open.times1");
        
        appOpen1.isEligibleForSearch = true;
        appOpen1.isEligibleForPublicIndexing = true;
        appOpen1.isEligibleForHandoff = true;
        
        appOpen1.title = "wollaaa";
        appOpen1.needsSave = true;
        appOpen1.keywords = ["wolla ","great ","chistmas","nownever","valid","runner"];
        var times1 = UserDefaults.standard.integer(forKey: KEY);
        times1 += 1;
        appOpen.userInfo = ["times":times1];
        UserDefaults.standard.set(times, forKey: KEY);
        
        userActivity = appOpen1;
        let sets1 = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String);
        sets1.authorNames = ["volla","ailaa"];
        sets1.contentDescription = "jaisi karni vaisi bharni";
        sets1.thumbnailData = UIImageJPEGRepresentation(UIImage(named: "AppIcon60x60")!, 1.0);
        sets1.supportsPhoneCall = true
        
        sets1.phoneNumbers = ["9173251265"]
        sets1.emailAddresses = ["wolaa@new.COM"]
        sets1.keywords = ["wolla ","great ","chistmas","nownever","valid","runner"];
        appOpen1.contentAttributeSet = sets
        
        
        // Create an item with a unique identifier, a domain identifier, and the attribute set you created earlier.
        let item = CSSearchableItem(uniqueIdentifier: "app.use.times", domainIdentifier: "file-1", attributeSet: sets)
        let item1 = CSSearchableItem(uniqueIdentifier: "app.use.times1", domainIdentifier: "file-2", attributeSet: sets)
        
        //        CSSearchableIndex.default().deleteAllSearchableItems(completionHandler: nil);
        
        CSSearchableIndex.default().indexSearchableItems([item,item1], completionHandler: {(error:Error?) -> Void  in
            
            print("error state: \(error)");
        })
        NSLog("CoreSpotlightAPIVersion %d", CoreSpotlightAPIVersion);
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(openApp), name: .UIApplicationWillEnterForeground , object: nil);
        updateUI();
        
        self.lblButton.isEnabled = false;
        
    }
    
    func speechDemo()
    {
        speechRecognizer?.delegate = self;
        var isButtonEnabled = true
        var msg = "";
        SFSpeechRecognizer.requestAuthorization { (status:SFSpeechRecognizerAuthorizationStatus) in
            
            switch status
            {
            case .authorized:
                
                isButtonEnabled = true
                msg = "Speech to text"
                
                break;
                
            case .denied , .notDetermined , .restricted:
                
                isButtonEnabled = false
                msg = "Allow application to use Speech services"
                
                break;
            }
            
            OperationQueue.main.addOperation {
                
                self.lblButton.isEnabled = isButtonEnabled;
                self.lblInfo.text = msg
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        self.speechDemo();
    }
    
    func updateUI()
    {
        if let userDefault = UserDefaults(suiteName: "group.appgroupintegration")
        {
            let counter = userDefault.integer(forKey: "counter");
            lblCounter.text = "\(counter)";
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openApp()
    {
        self.updateUI();
        
        
    }
    @IBAction func speechEnable(_ sender: UIButton) {
        
        
        
        if sender.tag != 1
        {
            // start speech
            sender.tag = 1;
            
            self.startRecording();
            sender.setTitle("Stop SIRI", for: .normal)
        }
        else
        {
            sender.tag = 2;
            //stop speech
            sender.setTitle("START SIRI", for: .normal)
            audioEngine.stop()
            audioEngine.reset();
            recognitionRequest?.endAudio()
        }
    }
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.lblSpeechValue.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.lblButton.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        lblInfo.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
           self.lblButton.isEnabled = true
        } else {
            self.lblButton.isEnabled = false
        }
    }
}

