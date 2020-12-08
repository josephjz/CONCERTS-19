//
//  LoginViewController.swift
//  CONCERTS-19
//
//  Created by Jennifer Joseph
//

import UIKit
import CoreLocation     // will use later for in-person concerts
import Firebase
import FirebaseUI
import GoogleSignIn

class LoginViewController: UIViewController {
    
    // declaring the authUI variable
    var authUI: FUIAuth!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // initializing the authUI var and setting the delegate
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    
    func signIn() {
        let providers: [FUIAuthProvider] = [
          FUIGoogleAuth(),
        ]   // this providers code creates the button for user to click for Google Sign In
        if authUI.auth?.currentUser == nil { // user has not signed in
            self.authUI.providers = providers // show providers named after let providers: above using pre built Google sign in login
            let loginViewController = authUI.authViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true, completion: nil)
        } else { // user is already logged in
            guard let currentUser = authUI.auth?.currentUser else {
                print("ERROR: Could not get current user")
                return
            }
            let concertUser = ConcertUser(user: currentUser)
            concertUser.saveIfNewUser { (success) in
                if success {
                    self.performSegue(withIdentifier: "FirstShowSegue", sender: nil)
                } else {
                    print("ERROR: Tried to save a new Concert User but failed.")
                }
            }
            performSegue(withIdentifier: "FirstShowSegue", sender: nil)
            // have a valid user, but want to check to see if we have userDoc for them
        }
    }
    
    func signOut() {
        do {
            try authUI!.signOut()
        } catch {
            print("😡 ERROR: couldn't sign out")
            performSegue(withIdentifier: "FirstShowSegue", sender: nil)
        }
    }
    
    @IBAction func unwindSignOutPressed(segue: UIStoryboardSegue) {
        if segue.identifier == "SignOutUnwind" {
            signOut()
        }
    }
}


// extension for FirebaseUI Authentication
extension LoginViewController : FUIAuthDelegate {
    
    // method is a handler for the result of a Google and Facebook sign up flow
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    // method verifies that a user has logged in, and if so, the tableView is shown
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user {
            // Assumes data will be isplayed in a tableView that was hidden until login was verified so unauthorized users can't see data.
            //tableView.isHidden = false
            print("^^^ We signed in with the user \(user.email ?? "unknown e-mail")")
        }
    }
    
    // customization code for logo
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        
        // create an instance of the FirebaseAuth Login View Controller
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        
        // set background color to white
        loginViewController.view.backgroundColor = UIColor.white
        
        // create a frame for a UIImageView to hold our logo
        let imageHeight: CGFloat = 500      // logo height
        let logoFrame = CGRect(x: 0, y: 20, width: self.view.frame.width, height: imageHeight)
        
        // create the UIImageView using the frame created above and add the "logo" image
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "HomeScreen")
        logoImageView.contentMode = .center     // set imageView to Aspect Fit
        logoImageView.contentMode = .scaleAspectFit     // set imageView to Aspect Fit
        loginViewController.view.addSubview(logoImageView)      // add imageView to the login controller's main view
        return loginViewController
    }
}


