#
#  AppDelegate.rb
#  GPGBoard
#
#  Created by Colin Dean on 3/8/13.
#  Copyright 2013 Colin Dean. All rights reserved.
#
require 'open3'

class AppDelegate
    attr_accessor :window
    
    attr_accessor :input_textarea
    attr_accessor :output_textarea
    attr_accessor :recipient_text
    attr_accessor :log_textarea
    attr_accessor :privkeys_popup
    
    def applicationDidFinishLaunching(a_notification)
        # Insert code here to initialize your application
        logg "initialized with:\n #{`gpg --version`}"
        load_private_keys
    end
    
    def load_private_keys
        cmd_output = `gpg -K`
        keys = cmd_output.split("\n").select{|l|l.match(/^sec/)}.collect{|m|m.match(/\d{4}\w{1}\/[\d\w]{8}/).to_s.split("/")[1]}
        @privkeys_popup_button = PopUpButtonWithArray.new(privkeys_popup, keys) #to setup the button's options
    end
    
    
    def sign_text sender
        key = "0x" + @privkeys_popup_button.get_selected
        logg "signing text with key #{key}"
        cmd_output = do_gpg_cmd("--clearsign --local-user #{key}")
        output_text cmd_output
    end
    
    def encrypt_text sender
        recipient = recipient_text.stringValue
        logg "encrypting for #{recipient}..."
        cmd_output = do_gpg_cmd("--armor --encrypt -r #{recipient}")
        output_text cmd_output

    end
    
    def decrypt_text sender
        key = "0x" + @privkeys_popup_button.get_selected
        logg "decrypting text as #{key}"
        cmd_output = do_gpg_cmd("--decrypt --local-user #{key}")
        output_text cmd_output
    end
    
    def verify_text sender
        logg "verifying text..."
        cmd_output = do_gpg_cmd("--verify")
        output_text cmd_output
    end
    
    def do_gpg_cmd cmd
        gpg = "gpg "
        cmd_output = ''
        logg "executing [#{cmd}]"
        Open3.popen3(gpg + cmd) do |stdin, stdout, stderr|
            stdin.write input_text
            stdin.close
            cmd_output = stdout.read_nonblock 2048
            stdout.close
            logg stderr.read
            stderr.close
        end
        return cmd_output
    end
    
    def logg text
        cv = log_textarea.enclosingScrollView.contentView
        scroll = NSMaxY(cv.documentVisibleRect) >= NSMaxY(cv.documentRect)
        log_textarea.setString log_textarea.textStorage.string + "\n" + text
        if scroll
            log_textarea.scrollRangeToVisible NSMakeRange(log_textarea.string.length, 0)
        end
    end
    
    def output_text text
        output_textarea.setString text
    end
    
    def input_text
        input_textarea.textStorage.string
    end
    
end

