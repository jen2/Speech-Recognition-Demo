//
//  SpeechDetectionViewController.swift
//  Speech-Recognition-Demo
//
//  Created by Jennifer A Sipila on 3/3/17.
//  Copyright © 2017 Jennifer A Sipila. All rights reserved.
//

import UIKit
import Speech

class SpeechDetectionViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var detectedTextLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var startButton: UIButton!
    
    let audioEngine = AVAudioEngine() //Will process the audio stream, we'll get updates from this when the mic receives audio.
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US")) //Recognizes the speech, this can fail and return nil, so it should be optional
    let request = SFSpeechAudioBufferRecognitionRequest() //Allocates speech as the user speaks, since we don't have the complete audio file.
    var recognitionTask: SFSpeechRecognitionTask? //Manages, cancels, or stops current recognition task.
    var isRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestSpeechAuthorization()
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if isRecording == true {
            audioEngine.stop()
            recognitionTask?.cancel()
            isRecording = false
            startButton.backgroundColor = UIColor.gray
        } else {
            self.recordAndRecognizeSpeech()
            isRecording = true
            startButton.backgroundColor = UIColor.red
        }
    }
    
    func cancelRecording() {
        audioEngine.stop()
        if let node = audioEngine.inputNode {
            node.removeTap(onBus: 0)
        }
        recognitionTask?.cancel()
    }

//MARK: - Authorization
    
    func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                case .denied:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "User denied access to speech recognition"
                case .restricted:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition restricted on this device"
                case .notDetermined:
                    self.startButton.isEnabled = false
                    self.detectedTextLabel.text = "Speech recognition not yet authorized"
                }
            }
        }
    }

//MARK: - Recognize Speech

    func recordAndRecognizeSpeech() {
        // Setup audio engine and speech recognizer
        guard let node = audioEngine.inputNode else { return }
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        // Prepare and start recording
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            // A recognizer is not supported for the current locale
            return
        }
        if !myRecognizer.isAvailable {
            // The recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                let bestString = result.bestTranscription.formattedString
                self.detectedTextLabel.text = bestString
                
                var lastString: String = ""
                for segment in result.bestTranscription.segments {
                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
                    lastString = bestString.substring(from: indexTo)
                }
                self.checkForColorsSaid(resultString: lastString)
            } else if let error = error {
                print(error)
            }
        })
    }
    
//MARK: - UI / Set view color.
    
    func checkForColorsSaid(resultString: String) {
        switch resultString {
        case "red":
            colorView.backgroundColor = UIColor.red
        case "orange":
            colorView.backgroundColor = UIColor.orange
        case "yellow":
            colorView.backgroundColor = UIColor.yellow
        case "green":
            colorView.backgroundColor = UIColor.green
        case "blue":
            colorView.backgroundColor = UIColor.blue
        case "purple":
            colorView.backgroundColor = UIColor.purple
        case "black":
            colorView.backgroundColor = UIColor.black
        case "white":
            colorView.backgroundColor = UIColor.white
        case "gray":
            colorView.backgroundColor = UIColor.gray
        default: break
        }
    }
}
