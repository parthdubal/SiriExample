//
//  IntentViewController.swift
//  SiriIntentUI
//
//  Created by Parth Dubal on 12/21/16.
//  Copyright © 2016 Parth Dubal. All rights reserved.
//

import IntentsUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling,INUIHostedViewSiriProviding {
   
    var displaysMap: Bool{
        return true;
    }
    var displaysPaymentTransaction: Bool{
        return true;
    }
    var displaysMessage: Bool {
        return false
    }

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMsg: UILabel!
    @IBOutlet weak var imgUser: UIImageView!
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("SIRI UIIII \(#function)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func  hideAllUI() -> Void
    {
        lblName.isHidden = true;
        lblMsg.isHidden = true;
        imgUser.isHidden = true;
        
        print("displaysMap: \(self.displaysMap)");
        print("displaysMessage: \(self.displaysMessage)");
        print("displaysPaymentTransaction: \(self.displaysPaymentTransaction)");
    }

    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configure(with interaction: INInteraction!, context: INUIHostedViewContext, completion: ((CGSize) -> Void)!) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
        
        self.hideAllUI();
        
        if let sendMessageIntent = interaction.intent as? INSendMessageIntent
        {
            
            if let recipient = sendMessageIntent.recipients?.first
            {
                lblName.isHidden = false;
                lblName.text = recipient.displayName;
            }
            print("sendMessageIntent.groupName \(sendMessageIntent.groupName)")
            
            print("sendMessageIntent.content \(sendMessageIntent.content)")
            if let msg = sendMessageIntent.content
            {
                lblMsg.isHidden = false;
                lblMsg.text = msg;
            }
        }
        
        if let completion = completion {
            completion(self.desiredSize)
        }
    }
    
    var desiredSize: CGSize {
        return self.extensionContext!.hostedViewMaximumAllowedSize
    }
    
}

