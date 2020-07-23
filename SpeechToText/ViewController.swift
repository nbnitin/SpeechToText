//
//  ViewController.swift
//  SpeechToText
//
//  Created by Nitin on 09/06/20.
//  Copyright © 2020 Nitin. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController,SFSpeechRecognizerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
   
    //variables
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "hi"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest? //This object handles the speech recognition requests. It provides an audio input to the speech recognizer.
    private var recognitionTask: SFSpeechRecognitionTask? //The recognition task where it gives you the result of the recognition request. Having this object is handy as you can cancel or stop the task.
    private let audioEngine : AVAudioEngine? = AVAudioEngine() //This is your audio engine. It is responsible for providing your audio input.
    var lang = ["English", "Hindi"]
    var values = ["en-US","hi"]


    var pickerView = UIPickerView()
    
    //outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtSpeechToText: UITextView!
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var txtChooseLanguage: UITextField!
    
    @IBOutlet weak var waveFormView: SCSiriWaveFormViewSwift!
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.dataSource = self
        pickerView.delegate = self

        txtChooseLanguage.delegate = self
        txtChooseLanguage.inputView = pickerView
        
        btnRecord.isEnabled = false  //2
        
        speechRecognizer!.delegate = self  //3
        
        txtChooseLanguage.text = lang[0]
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: values[0]))
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.btnRecord.isEnabled = isButtonEnabled
            }
        }
    }
    
    func updateMeters() {
        
        
//        let normalizedValue:CGFloat = pow(10, CGFloat(recorder.averagePowerForChannel(0))/20)
//        waveformView.updateWithLevel(normalizedValue)
    }
    
    @IBAction func btnRecordAction(_ sender: Any) {
        if audioEngine!.isRunning {
           stopRecording()
        } else {
            startRecording()
            btnRecord.setImage(UIImage(named: "stop"), for: .normal)
        }
    }
    
    
    func stopRecording(){
        audioEngine?.stop()
        recognitionRequest?.endAudio()
        btnRecord.isEnabled = false
        btnRecord.setImage(UIImage(named: "record"), for: .normal)
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            btnRecord.isEnabled = true
        } else {
            btnRecord.isEnabled = false
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
    
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine?.inputNode  else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.txtSpeechToText.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
                self.waveFormView.update(withLevel: CGFloat(inputNode.volume))
                
            }
            
            
            
            if error != nil || isFinal {
                self.audioEngine?.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.btnRecord.isEnabled = true
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        
        audioEngine?.prepare()
        
        do {
            try audioEngine?.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        txtSpeechToText.text = "Say something, I'm listening!"
        
    }
    
    //picker
    // returns the number of 'columns' to display.
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
           return 1

       }

   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return lang.count
      }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return lang[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        txtChooseLanguage.text = lang[row]
        stopRecording()
        speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: values[row]))
        
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
       // pickerBizCat.hidden = false
        return false
    }
}

