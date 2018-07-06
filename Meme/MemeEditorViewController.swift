//
//  ViewController.swift
//  Meme
//
//  Created by Shreyak Godala on 28/06/18.
//  Copyright © 2018 Shreyak Godala. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    var memes: [Meme] = [] 
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // Outlets
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    
    @IBOutlet weak var memeImage: UIImageView!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    let memeTextAttributes: [String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "Impact", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        shareButton.isEnabled = false
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        topTextField.text = "TOP"
        topTextField.textAlignment = .center
        bottomTextField.text = "BOTTOM"
        bottomTextField.textAlignment = .center
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeForKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeForKeyboardNotification()
    }
    
    

    
    func saveMeme() {
        // create meme
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: memeImage.image!, memedImage: generateMemedImage())
        
        // add meme to memes array
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        
    }
    
//    func calculateRectOfImageInImageView(imageView: UIImageView) -> CGRect {
//        let imageViewSize = imageView.frame.size
//        let imgSize = imageView.image?.size
//
//        guard let imageSize = imgSize, imgSize != nil else {
//            return CGRect.zero
//        }
//
//        let scaleWidth = imageViewSize.width / imageSize.width
//        let scaleHeight = imageViewSize.height / imageSize.height
//        let aspect = fmin(scaleWidth, scaleHeight)
//
//        var imageRect = CGRect(x: 0, y: 0, width: imageSize.width * aspect, height: imageSize.height * aspect)
//        // Center image
//        imageRect.origin.x = (imageViewSize.width - imageRect.size.width) / 2
//        imageRect.origin.y = (imageViewSize.height - imageRect.size.height) / 2
//
//        // Add imageView offset
//        imageRect.origin.x += imageView.frame.origin.x
//        imageRect.origin.y += imageView.frame.origin.y
//
//        return imageRect
//    }

    
    func generateMemedImage() -> UIImage {
        
        
        
        // Hide nav and toolbar
        navBar.isHidden = true
        toolbar.isHidden = true
        
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // Show nav and toolbar
        navBar.isHidden = false
        toolbar.isHidden = false
        
        
        
        return memedImage
        
    }

    // Actions
    
    @IBAction func pickButtonTapped(_ sender: UIBarButtonItem) {
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        
        picker.sourceType = .photoLibrary
        
        present(picker, animated: true, completion: nil)
        
        
        
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIBarButtonItem) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {
        
        let memedImage = generateMemedImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {
            (activityType,completed,returnedItems,error) in
            
            if completed {
                self.saveMeme()
                self.dismiss(animated: true, completion: nil)
                
                
            } else {
                print("User cancelled")
            }
            
        }
        
        self.present(activityController, animated: true)
        
        
    }
    
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        memeImage.image = UIImage()
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        shareButton.isEnabled = false
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    // handling keyboard notifications for bottom Textfield
    
    func subscribeForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeForKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
        view.frame.origin.y -= getKeyboardHeight(notification)
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
        
        
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    // ImagePickerDelegates
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            memeImage.image = image
            shareButton.isEnabled = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // TextFieldDelegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        topTextField.resignFirstResponder()
        bottomTextField.resignFirstResponder()
        return true
    }
    
    
    
}

