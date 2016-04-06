//
//  TCPServerViewController.swift
//  socket
//
//  Created by Hongyi Guo on 03/25/2016.
//  Copyright (c) 2016 Hongyi Guo. All rights reserved.
//

import UIKit

class TCPServerViewController: UIViewController {
    
    @IBOutlet weak var localIP: UILabel!
    
    @IBOutlet weak var port: UITextField!
    
    @IBOutlet weak var sendedMsg: UITextField!
    
    @IBOutlet weak var receivedMsg: UILabel!
    
    var server: TCPServer!
    
    override func viewDidLoad() {
        let ipUtil = IPAddress()
        
        self.localIP.text = ipUtil.getIPAddress(true)
        
        self.receivedMsg.text = nil
        self.port.delegate = self
        self.sendedMsg.delegate = self
    }
    
    @IBAction func bind(sender: UIButton) {
        
        if self.server != nil {
            self.server.close()
        }
        
        self.server = TCPServer(addr: self.localIP.text!, port: Int(self.port.text!)!)
        self.server.delegate = self
        
        self.server.start()
        
    }
    
    @IBAction func sendMsg(sender: AnyObject) {
        if let sv = self.server {
            sv.send(self.sendedMsg.text!)
        }
    }

    func alert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

extension TCPServerViewController: TCPServerDelegate {
    
    func server(server: TCPServer, serverIsWorking isWorking: Bool) {
        print(isWorking)
        
        alert("Alert", msg: "server is work: \(isWorking)")
    }
    
    func server(server: TCPServer, connectedClient client: TCPClient) {
        print(client.addr)
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.alert("Alert", msg: "connected client addr: \(client.addr)")
        }
    }
    
    func server(server: TCPServer, client: TCPClient, receivedData data: NSData) {
        
        var packet:NSString?
        if let msg = NSString(data: data, encoding: NSUTF8StringEncoding) {
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.receivedMsg.text = "\(client.addr):\(msg)"
                packet = msg
            }
        }
        if packet == "setUpPeerToPeer"{
            self.alert("Processing", msg: "Setting up peer to peer")
        }
    }
}

extension TCPServerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
