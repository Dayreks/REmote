//
//  ChooseEmotionViewController.swift
//  REmote
//
//  Created by Dmytro Hetman on 29.06.2022.
//

import UIKit

class ChooseEmotionViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet private weak var pickerView: UIPickerView!
    @IBOutlet private weak var chooseEmotionButton: UIButton!
    
    //MARK: - Properties
    var currentEmotion = ""
   
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        self.chooseEmotionButton.addTarget(self, action: #selector(chooseEmotion), for: .touchUpInside)
        
    }
    
    @objc
    private func chooseEmotion() {
        for em in Emotion.allCases {
            if currentEmotion == em.rawValue {
                let emotion = em.rawValue
                ImageRepository.shared.emotionForCurrentLoad = emotion
                print(ImageRepository.shared.emotionForCurrentLoad)
            }
        }
        
        
    }

    
    
}

extension ChooseEmotionViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Emotion.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        currentEmotion = Emotion.allCases[row].rawValue
        return Emotion.allCases[row].rawValue
    }
    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        currentEmotion = Emotion.allCases[row].rawValue
//    }
    
}
