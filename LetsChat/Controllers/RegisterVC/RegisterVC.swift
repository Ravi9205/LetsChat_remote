//
//  RegisterVC.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 23/03/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterVC: UIViewController {
    
    
    private let spinner = JGProgressHUD(style: .dark)

    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.isUserInteractionEnabled = true
        return scrollView
        
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"person.circle")
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        return imageView
        
    }()
    
    
    private let firstNameField:UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Enter First Name.... "
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        return textField
        
    }()
    
    private let lastNameField:UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Enter Last Name.... "
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        return textField
        
    }()
    
    private let emailField:UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Enter Email Address.... "
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        return textField
        
    }()
    
    
    private let passwordField:UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Enter Password .... "
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.isSecureTextEntry = true
        textField.backgroundColor = .white
        return textField
        
    }()
    
    private let registerButton:UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20,weight:.bold)
        return button
        
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Register User"
        self.view.backgroundColor = .white
        
        firstNameField.delegate = self
        lastNameField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        
        scrollView.addSubview(passwordField)
        scrollView.addSubview(registerButton)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(openPhotoGallery))
        gesture.numberOfTouchesRequired = 1
        gesture.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(gesture)
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        registerButton.addTarget(self, action: #selector(registerUserButtonTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 50,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = imageView.width/2.0
        
        firstNameField.frame = CGRect(x: 30,
                                      y: imageView.bottom+50,
                                      width: scrollView.width-60,
                                      height: 52)
        
        lastNameField.frame = CGRect(x: 30,
                                     y: firstNameField.bottom+20,
                                     width: scrollView.width-60,
                                     height: 52)
        
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom+20,
                                  width: scrollView.width-60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+20,
                                     width: scrollView.width-60,
                                     height: 52)
        
        
        registerButton.frame = CGRect(x: 30,
                                      y: passwordField.bottom+20,
                                      width: scrollView.width-60,
                                      height: 52)
        
    }
    
    
    @objc func registerUserButtonTapped() {
        
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let firstName = firstNameField.text ,let lastNameField = lastNameField.text, let email = emailField.text,let password = passwordField.text , !firstName.isEmpty, !lastNameField.isEmpty ,!email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserSignUpError(message:"Please enter all information to create a new account")
            return
        }
        
        // Firebase login
        spinner.show(in: view)

        
        DatabaseManager.shared.userExits(with: email) {[weak self] emailExits in
            
            guard let strongSelf = self else {
                return
            }
            
            guard !emailExits else {
                //user Already exits
                return
            }
            
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                
                DispatchQueue.main.async {
                    strongSelf.spinner.dismiss()

                }
                
                guard  authResult != nil, error == nil else {
                    //print("error creating new account\(String(describing: error))")
                    strongSelf.alertUserSignUpError(message: String(describing:error))
                    return
                }
                
                //let user = result.user
                
                DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastNameField, emailAddress: email))
                // print("Created \(user)")
                guard let message = strongSelf.storyboard?.instantiateViewController(withIdentifier:"MessageVC") as? MessageVC else { return}
                strongSelf.navigationController?.pushViewController(message, animated: false)
                
            }
        }
        
        
        
    }
    
    func alertUserSignUpError(message:String){
        let alert = UIAlertController(title:"Woops", message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    @objc func  openPhotoGallery(){
        //print("Open gallery")
        presentPhotoActionSheet()
    }
    
    
}

// MARK:- TextField Delegates

extension RegisterVC:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        }
        else if textField == lastNameField
        {
            passwordField.becomeFirstResponder()
        }
        else if textField == emailField
        {
            emailField.becomeFirstResponder()
        }
        
        else if textField == passwordField{
            registerUserButtonTapped()
        }
        
        return true
    }
}


//MARK:- For Accessing the Media Liabrary

extension RegisterVC:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet(){
        let actionSheet  = UIAlertController(title:"Profile Picture", message:"How would you like to select a picture !", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: {[weak self]_ in
            self?.presentCamera()
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Chose Photo",
                                            style: .default,
                                            handler: {[weak self]_ in
            self?.presentPhotoPicker()
            
        }))
        present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK:- Opening up Camera
    func presentCamera(){
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true)
            
        }
        else
        {
            let cameraAlert = UIAlertController(title:"Woops!", message:"Camera not avaiable for this selected device try different one", preferredStyle: .alert)
            cameraAlert.addAction(UIAlertAction(title:"Dismiss", style: .cancel, handler: nil))
            self.present(cameraAlert, animated: true)
            
        }
    }
    
    //MARK:- Photo Gallery
    func presentPhotoPicker(){
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        imageView.image = selectedImage
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}


