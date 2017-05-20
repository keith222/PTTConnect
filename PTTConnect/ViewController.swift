//
//  ViewController.swift
//  PTTConnect
//
//  Created by Yang Tun-Kai on 2016/5/19.
//  Copyright © 2016年 Yang Tun-Kai. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ViewController: UIViewController{

    var socket: GCDAsyncSocket!
    
    fileprivate let host: String! = "ptt.cc"
    fileprivate let port: UInt16 = 23
    fileprivate let big5 = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.big5.rawValue))

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    @IBAction func enterAction(_ sender: AnyObject) {
        
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        
        do {
            try self.socket.connect(toHost: host, onPort: port, withTimeout: -1)
            //enter account
            pttCommand(self.accountTextField.text!)
        }
        catch {
            print("oops")
        }
    }
    
    @IBAction func commandAction(_ sender: AnyObject) {
        pttCommand("U")
        pttCommand("i")
    }
    func pttCommand(_ command:String){
        let sendString = command + "\r\n"
        let commandData = sendString.data(using: String.Encoding(rawValue: big5))
        
        let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.socket.write(commandData, withTimeout: -1.0, tag: 0)
            self.socket.readData(withTimeout: -1.0, tag: 0)
        }
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("connected")
    }
    
    func socket(_ sock: GCDAsyncSocket, didReadData data: Data, withTag tag: Int32){
        sock.readData(withTimeout: -1, tag: 0)
        let response = String(data: data, encoding: String.Encoding(rawValue: big5))
        print("response:\(String(describing: response))")
        
        
        if response?.range(of: "請輸入您的密碼") != nil{
            pttCommand(self.passwordTextField.text!)
        }else if response?.range(of: "您想刪除其他重複登入的連線嗎") != nil{
            pttCommand("n")
        }else if response?.range(of: "請按任意鍵繼續") != nil{
            //continue command
            pttCommand("")
            pttCommand("u")
            pttCommand("i")
        }else if response?.range(of: "您要刪除以上錯誤嘗試的記錄嗎") != nil{
            pttCommand("y")
        }else if response?.range(of: "代號暱稱") != nil{
            let start = response?.range(of: "登入次數")?.upperBound
            let end = response?.range(of: " 次")?.lowerBound
            DispatchQueue.main.async(execute: {
                self.loginTimeLabel.text = response?.substring(with: Range<String.Index>(start!..<end!))
            })
            

        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

