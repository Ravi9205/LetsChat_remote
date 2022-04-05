//
//  LoginVC.swift
//  LetsChat
//
//  Created by Ravi Dwivedi on 23/03/22.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import FirebaseCore
import JGProgressHUD

class LoginVC: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
        
    }()
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named:"Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
        
    }()
    
    
    private let emailField:UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Enter Email address.... "
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        return textField
        
    }()
    
    private let facebookloginButton : FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    private let googleSignButton:GIDSignInButton = {
        let button = GIDSignInButton()
        return button
        
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
    
    
    private let loginButton:UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = .link
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20,weight:.bold)
        return button
        
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        self.view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register"
                                                                 , style: .done,
                                                                 target: self,
                                                                 action: #selector(registerTapped))
        
        
        
        
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookloginButton)
        scrollView.addSubview(googleSignButton)
        
        
        emailField.delegate = self
        passwordField.delegate = self
        facebookloginButton.delegate = self
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        googleSignButton.addTarget(self, action: #selector(googleSignTapped), for: .touchUpInside)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 50,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+50,
                                  width: scrollView.width-60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+20,
                                     width: scrollView.width-60,
                                     height: 52)
        
        
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+20,
                                   width: scrollView.width-60,
                                   height: 52)
        
        // FB SDK Login Button Frame and Layout setup
        
        facebookloginButton.frame = CGRect(x: 30,
                                           y: loginButton.bottom+20,
                                           width: scrollView.width-60,
                                           height: 52)
        
        
        //facebookloginButton.center = scrollView.center
        facebookloginButton.frame.origin.y = loginButton.bottom + 20
        
        googleSignButton.frame = CGRect(x: 30,
                                        y: facebookloginButton.bottom+20,
                                        width: scrollView.width-60,
                                        height: 52)
        googleSignButton.frame.origin.y = facebookloginButton.bottom + 20
        
        
    }
    
    
    @objc func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text , let password = passwordField.text , !email.isEmpty , !password.isEmpty, password.count >= 6 else {
            alertUserLoginError(message:"Please enter all information to login")
            return
        }
        
        // Firebase login
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
                
            }
            
            guard let result = authResult, error == nil else {
                print("Error while login")
                return
            }
            
            let user = result.user
            print("userInfo==\(user)")
            let tabbar = strongSelf.storyboard?.instantiateViewController(withIdentifier:"TabbarController")
            let nav = UINavigationController(rootViewController: tabbar!)
            nav.modalPresentationStyle = .fullScreen
            strongSelf.present(nav, animated: false, completion: nil)
        }
        
    }
    
    func alertUserLoginError(message:String){
        let alert = UIAlertController(title:"Woops", message:message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    
    
    @objc func registerTapped(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier:"RegisterVC") as! RegisterVC
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    
    @objc func googleSignTapped() {
        googleSign()
    }
    
}

extension LoginVC:UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField{
            loginButtonTapped()
        }
        
        return true
    }
}

//MARK:- Facebook Login Button Delegate

extension LoginVC:LoginButtonDelegate{
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        guard let token = result?.token?.tokenString else {
            print("user failed to login with facebook")
            return
        }
        
        
        let facebookRquest = FBSDKLoginKit.GraphRequest(graphPath:"me", parameters: ["fields":"email,first_name,last_name,picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRquest.start { _, result, error in
            
            guard let  result = result as? [String:Any] , error == nil else {
                print("error fetching facebook Data")
                
                return
            }
            print("\(result)")
            
            guard let firstName = result["first_name"] as? String, let lastName = result["last_name"] as? String, let facebookEmail = result["email"] as? String, let picture = result["picture"] as? [String:Any], let imgData = picture["data"] as? [String:Any],let pictureURL = imgData["url"] as? String  else {
                print("Failed to get email and first & last name from facebook")
                return
            }
            
            
            
            DatabaseManager.shared.userExits(with: facebookEmail) { exits in
                
                if !exits {
                    let chatUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: facebookEmail)
                    DatabaseManager.shared.insertUser(with:chatUser) {  success in
                        if success {
                            //Insert into data base
                            
                            guard let url = URL(string: pictureURL) else {
                                return
                            }
                            
                            URLSession.shared.dataTask(with: url) { downloadedImgData, dataResponse, error in
                                
                                
                                guard let data = downloadedImgData else {
                                    print("Error while fetching image data from facebook")
                                    return
                                }
                                
                                
                                let filename =  chatUser.profilePictureFileName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: filename) { result  in
                                    
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.setValue(downloadUrl, forKey:"profile_picture_url")
                                        print(downloadUrl)
                                    case.failure( let error):
                                        print("Storaage manager error\(error)")
                                        
                                    }
                                }
                                
                            }.resume()
                        }
                    }
                }
                
            }
            
            let credentails = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credentails) { [weak self] authResult, error in
                
                guard let strongSelf = self else {
                    return
                }
                
                guard let result = authResult, error == nil else {
                    
                    if let error = error {
                        strongSelf.alertUserLoginError(message:error.localizedDescription)
                        
                    }
                    return
                }
                print("Successfully logged user In===\(result)")
                //strongSelf.navigationController?.dismiss(animated: false, completion: nil)
                
                let tabbar = strongSelf.storyboard?.instantiateViewController(withIdentifier:"TabbarController")
                let nav = UINavigationController(rootViewController: tabbar!)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: false, completion: nil)
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation needed
    }
    
    
}


// MARK:- Google Sign

extension LoginVC {
    
    private func googleSign() {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [weak self] user, error in
            
            guard let strongSelf = self else {
                return
            }
            
            if let error = error {
                // ...
                strongSelf.alertUserLoginError(message:error.localizedDescription)
                return
            }
            
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                print("Missing the user Authentication with google")
                return
            }
            
            print("Signed in with Google=====\(String(describing: user))")
            
            guard let email = user?.profile?.email , let firstName = user?.profile?.givenName, let lastName = user?.profile?.familyName else {
                return
            }
            
            DatabaseManager.shared.userExits(with: email) { exits in
                if !exits {
                    
                    let chatAppUser = ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatAppUser) { success in
                        if success {
                            // Upload Images to firebase store
                            
                            if ((user?.profile?.hasImage) != nil) {
                                
                                guard let url = user?.profile?.imageURL(withDimension:200) else {
                                    return
                                }
                                
                                URLSession.shared.dataTask(with: url) { downloadedImgData, dataResponse, error in
                                    
                                    
                                    guard let data = downloadedImgData else {
                                        print("Error while fetching image data from facebook")
                                        return
                                    }
                                    
                                    
                                    let filename =  chatAppUser.profilePictureFileName
                                    StorageManager.shared.uploadProfilePicture(with: data, fileName: filename) { result  in
                                        
                                        switch result {
                                        case .success(let downloadUrl):
                                            UserDefaults.standard.setValue(downloadUrl, forKey:"profile_picture_url")
                                            print(downloadUrl)
                                        case.failure( let error):
                                            print("Storaage manager error\(error)")
                                            
                                        }
                                    }
                                }.resume()
                                
                            }
                        }
                    }
                }
                
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: authentication.accessToken)
                FirebaseAuth.Auth.auth().signIn(with:credential) { authResult, error in
                    
                    guard  authResult != nil, error == nil else {
                        // print("Error signin With Google using firebase")
                        if let error = error {
                            strongSelf.alertUserLoginError(message:error.localizedDescription)
                            
                        }
                        return
                    }
                    
                    print("Signed in successfully")
                    
                    let tabbar = strongSelf.storyboard?.instantiateViewController(withIdentifier:"TabbarController")
                    let nav = UINavigationController(rootViewController: tabbar!)
                    nav.modalPresentationStyle = .fullScreen
                    strongSelf.present(nav, animated: false, completion: nil)
                    
                }
            }
        }
        
    }
}
