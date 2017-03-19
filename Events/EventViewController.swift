//
//  EventViewController.swift
//  Events
//
//  Created by Martin Futas on 05/03/2017.
//  Copyright © 2017 Salesforce. All rights reserved.
//

import UIKit

class EventViewController: UIViewController {
    
    @IBOutlet weak var eventName: UILabel!
    var stringPassed = ""

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil);
//        let vc = storyboard.instantiateViewController(withIdentifier: "EventsScreen")
//        self.present(vc, animated: true, completion: nil);
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        eventName.text = stringPassed
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
