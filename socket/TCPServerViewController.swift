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
    
    @IBOutlet weak var carIP: UILabel!
    
    @IBOutlet weak var sendedMsg: UITextField!
    
    @IBOutlet weak var receivedMsg: UILabel!
    
    var server: TCPServer!
    
    var client: TCPClient!
    
    var clientIP: String!
    
    var clientPort: Int!
    
    
    override func viewDidLoad() {
        let ipUtil = IPAddress()
        
        self.localIP.text = ipUtil.getIPAddress(true)
        
        self.receivedMsg.text = nil
        self.port.delegate = self
        self.sendedMsg.delegate = self
        
        self.carIP.text = self.clientIP


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
            self?.carIP.text = "\(client.addr)"   
        }
        
        // Show CarIP on the mainboard
        //self.carIP.text = client.addr as String
        //self.carIP.text = "HEHE"

        
    }
    
    func server(server: TCPServer, client: TCPClient, receivedData data: NSData) {
        
        if let msg = NSString(data: data, encoding: NSUTF8StringEncoding) {
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                self?.receivedMsg.text = "\(client.addr):\(msg)"
                
           // dispatch_async(dispatch_get_main_queue()) { [weak self] in
            //    self?.carIP.text = "\(client.addr)"
            
                print(msg)
                print("client port is:")
                print(client.port)
                if msg == "setPeerToPeer" {
                    self!.alert("Alert", msg: "Setting up peer to peer")
                    
                    if self?.client != nil{
                        self?.client.close()
                    }
                    self?.clientIP = client.addr
                    self?.clientPort = client.port
                    
                    //self!.client = TCPClient(addr: self!.clientIP, port: self!.clientPort)
                    self!.client = TCPClient(addr: self!.clientIP, port: 17642)
                    self?.client.connectServer(timeout: 10)
                    
                    // To be continue
                    
                    //
                    
                    
                }
                else{
                    self!.alert("Alert", msg: msg as String)
                }
                
            }
        }

    }
}

extension TCPServerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
