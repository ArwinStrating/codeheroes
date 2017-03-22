//
//  LoginController.swift
//  Code Heroes
//
//  Created by Arwin Strating on 28-02-17.
//  Copyright © 2017 Arwin Strating. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import OAuthSwift
import PKHUD

class LoginController: OAuthViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var githubButton: UIButton!
    
    var oauthswift: OAuthSwift?
    
    lazy var internalWebViewController: WebViewController = {
        let controller = WebViewController()
        controller.view = UIView(frame: UIScreen.main.bounds)
        controller.viewDidLoad()
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if FIRAuth.auth()?.currentUser != nil {
            print((FIRAuth.auth()?.currentUser?.displayName)! as String)
            DispatchQueue.main.async(execute: { () -> Void in
                self.performSegue(withIdentifier: "authSuccess", sender: self)
            })
        } else {
            //User Not logged in
            print("No user")
        }

        // Set rounded corners for textfields and button
        githubButton.layer.cornerRadius = 5
        githubButton.layer.borderWidth = 1
        githubButton.layer.borderColor = UIColor.white.cgColor
        githubButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        
        // Set navigationbar background
        let navBackgroundImage:UIImage! = UIImage(named: "bg")
        UINavigationBar.appearance().setBackgroundImage(navBackgroundImage, for: .default)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Dismiss keyboard by tapping anywhere in view
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    // Dismiss keyboard by tapping return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func loginWithGithub(_ sender: Any) {
        
        //User Not logged in
        doOAuthGithub()
        
    }
    
    func doOAuthGithub(){
        let oauthswift = OAuth2Swift(
            consumerKey:    "c56f63865b8c54cf2569",
            consumerSecret: "8f149875904362dd1ac4dbc887342ade99af2d37",
            authorizeUrl:   "https://github.com/login/oauth/authorize",
            accessTokenUrl: "https://github.com/login/oauth/access_token",
            responseType:   "code"
        )
        self.oauthswift = oauthswift
        oauthswift.authorizeURLHandler = internalWebViewController
        //oauthswift.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: oauthswift)
        let state = generateState(withLength: 20)
        let _ = oauthswift.authorize(
            withCallbackURL: URL(string: "https://m4m-code-heroes.firebaseapp.com/__/auth/handler")!, scope: "user,repo", state: state,
            success: { credential, response, parameters in
                print("token: " + credential.oauthToken)
                let accessToken = credential.oauthToken
                let credentialFir = FIRGitHubAuthProvider.credential(withToken: accessToken)
                self.authWithFirebase(credential: credentialFir)
                PKHUD.sharedHUD.contentView = PKHUDSuccessView()
                PKHUD.sharedHUD.show()
        },
            failure: { error in
                print(error.description)
        }
        )
    }
        
    func authWithFirebase(credential: FIRAuthCredential) {
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                PKHUD.sharedHUD.hide()
                self.performSegue(withIdentifier: "authSuccess", sender: self)
                if error != nil {
                    return
                }
        }
    }
}

extension LoginController: OAuthWebViewControllerDelegate {
    
    func oauthWebViewControllerDidPresent() {
        
    }
    func oauthWebViewControllerDidDismiss() {
        
    }
    func oauthWebViewControllerWillAppear() {
        
    }
    func oauthWebViewControllerDidAppear() {
        
    }
    func oauthWebViewControllerWillDisappear() {
        
    }
    func oauthWebViewControllerDidDisappear() {
        // Ensure all listeners are removed if presented web view close
        oauthswift?.cancel()
    }
}


