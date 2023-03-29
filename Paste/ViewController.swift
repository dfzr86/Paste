//
//  ViewController.swift
//  Paste
//
//  Created by hanxu on 2022/11/24.
//

import Cocoa
import Carbon
import AppKit
import Foundation


class PastTextView: NSTextView {
    var mouseDownBlock: ((String) -> Void)?
    
    override func mouseDown(with event: NSEvent) {
        self.mouseDownBlock?(string)
    }
}

class PastHistoryView: NSScrollView, NSTextViewDelegate {
    var mouseDownBlock: ((String) -> Void)?
    
    let itemWidth: CGFloat = 240
    let gap: CGFloat = 20
    let maxSaveCount: Int = 50
    
    var prevPastBoardChangeCount: Int = 0
    
    var kv: [String: String] = [:]
    var array = [String]()
    
    lazy var stackView: NSStackView = {
        let stack = NSStackView(frame: .zero)
        stack.orientation = .horizontal
        stack.spacing = gap
        return stack
    }()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addTimer()
        documentView = stackView
    }
    
    @objc func checkPastBoard() {
        let currentPastBoardCount = NSPasteboard.general.changeCount
//        print("pastBoardCount: \(currentPastBoardCount)")
        
        guard currentPastBoardCount > prevPastBoardChangeCount,
              let string = NSPasteboard.general.string(forType: .string),
              !array.contains(string)
        else {
            return
        }
        prevPastBoardChangeCount = currentPastBoardCount
        kv[String(currentPastBoardCount)] = string
        array.append(string)
        if array.count > maxSaveCount {
            array.removeFirst()
            stackView.arrangedSubviews.last?.removeFromSuperview()
        }
        insert(str: array.last)
        stackView.frame = .init(x: 0, y: 0, width: CGFloat(array.count) * (itemWidth + gap), height: bounds.height)
    }
    
    override var contentSize: NSSize {
        return CGSize(width: CGFloat(array.count) * (itemWidth + gap), height: bounds.height)
    }
    
    func insert(str: String?) {
        guard let str = str else { return }
        let label = PastTextView()
        label.mouseDownBlock = { [weak self] text in
            self?.mouseDownBlock?(text)
        }
        label.delegate = self
        label.isEditable = false
        label.string = str
        label.font = NSFont.systemFont(ofSize: 24)
        stackView.insertArrangedSubview(label, at: 0)
        label.snp.makeConstraints { make in
            make.height.width.equalTo(itemWidth)
        }
    }
    
    func rebuild() {
        stackView.arrangedSubviews.forEach { v in
            v.removeFromSuperview()
        }
        array.forEach { str in
            insert(str: str)
        }
    }
    
    private func addTimer() {
        let timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(checkPastBoard), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }
    
    override func layout() {
        super.layout()
        stackView.layer?.backgroundColor = NSColor(calibratedRed: 226 / 255.0, green: 226 / 255.0, blue: 226 / 255.0, alpha: 1).cgColor
        backgroundColor = NSColor(calibratedRed: 226 / 255.0, green: 226 / 255.0, blue: 226 / 255.0, alpha: 1)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


public func dispatch_after_delay(_ delay: TimeInterval, queue: DispatchQueue, block: @escaping () -> Void) {
    let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    queue.asyncAfter(deadline: time, execute: block)
}


class ViewController: NSViewController, NSTextViewDelegate {
    
    var item: NSStatusItem?
    
    let pastWindow = NSWindow()
    lazy var pastView: PastHistoryView = {
        let v = PastHistoryView(frame: .zero)
        v.mouseDownBlock = { [weak self] text in
            guard let self = self else { return }
            self.hide()
            self.insertSomething(str: text)
            
        }
        return v
    }()
    
    @objc func insertSomething(str: String) {
        let pastBoard = NSPasteboard.general
        pastBoard.declareTypes([.string], owner: nil)
        pastBoard.setString(str, forType: .string)
        
        let script = """
        tell application "System Events"
            keystroke "v" using {command down}
        end tell
        """
        var error: NSDictionary?
        let appleScript = NSAppleScript(source: script)
        
        DispatchQueue.global().async {
            let result = appleScript?.executeAndReturnError(&error)
            if let error = error {
                print("Error: \(error)")
            }
            if let result = result?.stringValue {
                print("Result: \(result)")
            }
        }
    }
    
    func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        return true
    }
    
    let runningApp = NSRunningApplication.current
    
    private func addStatusBar() {
        item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item?.button?.image = NSImage(named: "icon")
    }
    private func addClickNoti() {
        HotKey.addGlobalHotKey(UInt32(kVK_ANSI_V))
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "cmd_shift_v_clicked"), object: nil, queue: .main) { [weak self] noti in
            guard let self = self else { return }
            self.show()
        }
    }
    
    private func addObserver() {
        runningApp.addObserver(self, forKeyPath: "active", context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "active" && runningApp.isActive == false {
            hide()
        }
    }
    
    private func configWindow() {
        pastWindow.contentView = pastView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addStatusBar()
        addClickNoti()
        addObserver()
        configWindow()
        
        let button = NSButton(title: "Show/Hide", target: self, action: #selector(show))
        view.addSubview(button)
        setWindowFull(pastWindow)
        //
        let input = NSTextView(frame: .init(x: 0, y: 0, width: 400, height: 88))
        input.delegate = self
        view.addSubview(input)
    }
    
    @objc func show() {
        if runningApp.isActive {
            return hide()
        }
        runningApp.activate(options: .activateAllWindows)
        NSWorkspace.shared.openApplication(at: URL(filePath: "/Applications/Paste.app"), configuration: NSWorkspace.OpenConfiguration())
    }
    
    @objc func hide() {
        runningApp.hide()
    }
    
    func setWindowFull(_ window: NSWindow?) {
        print("running: \(NSRunningApplication.current)")
        
        window?.level = .modalPanel
        window?.styleMask = [.borderless, .nonactivatingPanel]
        window?.collectionBehavior = [.canJoinAllSpaces, .fullScreenPrimary]
        window?.makeKeyAndOrderFront(nil)//使window显示在最前面
        
        //全屏
        let screenFrame = NSScreen.main?.frame ?? NSRect.zero
        let frame = CGRect.init(x: 0, y: 0, width: screenFrame.width, height: 300)
        window?.setFrame(frame, display: true)
        pastView.frame = frame
    }
}
