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
    
    private let host: String! = "ptt.cc"
    private let port: UInt16 = 23
    private let big5 = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.Big5.rawValue))

    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        
    }
    
    @IBAction func enterAction(sender: AnyObject) {
        
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: dispatch_get_main_queue())
        
        do {
            try self.socket.connectToHost(host, onPort: port, withTimeout: -1)
            //enter account
            pttCommand(self.accountTextField.text!)
        }
        catch {
            print("oops")
        }
    }
    
    @IBAction func commandAction(sender: AnyObject) {
        pttCommand("U")
        pttCommand("i")
    }
    func pttCommand(command:String){
        let sendString = command.stringByAppendingString("\r\n")
        let commandData = sendString.dataUsingEncoding(big5)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.socket.writeData(commandData, withTimeout: -1.0, tag: 0)
            self.socket.readDataWithTimeout(-1.0, tag: 0)
        }
        
    }
    
    func socket(sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("connected")
    }
    
    func socket(sock: GCDAsyncSocket, didReadData data: NSData, withTag tag: Int32){
        sock.readDataWithTimeout(-1, tag: 0)
        let response = String(data: data, encoding: big5)
        print("response:\(response)")
        
        
        if response?.rangeOfString("請輸入您的密碼") != nil{
            pttCommand(self.passwordTextField.text!)
        }else if response?.rangeOfString("您想刪除其他重複登入的連線嗎") != nil{
            pttCommand("n")
        }else if response?.rangeOfString("請按任意鍵繼續") != nil{
            //continue command
            pttCommand("")
            pttCommand("u")
            pttCommand("i")
        }else if response?.rangeOfString("您要刪除以上錯誤嘗試的記錄嗎") != nil{
            pttCommand("y")
        }else if response?.rangeOfString("代號暱稱") != nil{
            let start = response?.rangeOfString("登入次數")?.endIndex
            let end = response?.rangeOfString(" 次")?.startIndex
            dispatch_async(dispatch_get_main_queue(), {
                self.loginTimeLabel.text = response?.substringWithRange(Range<String.Index>(start!..<end!))
            })
            

        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

