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
    
    def applicationDidFinishLaunching(a_notification)
        # Insert code here to initialize your application
    end
    
    
    def sign_text sender
        output_textarea.setString "sign"
        output_textarea.setNeedsDisplay true
    end
    
    def encrypt_text sender
        cmd_output = ''
        recipient = recipient_text.stringValue
        logg "encrypting for #{recipient}..."
        Open3.popen3("gpg --armor --encrypt -r #{recipient}") do |stdin, stdout, stderr|
            stdin.puts input_textarea.stringValue
            stdin.close
            cmd_output = stdout.gets
            stdout.close
            puts stderr
            stderr.close
        end
        output_textarea.setString cmd_output

    end
    
    def decrypt_text sender
        output_textarea.setString "decrypt"
    end
    
    def verify_text sender
        output_textarea.setString `hostname`
    end
    
    def clear_output sender
        output_textarea.setString ""
        cmd_output = ''
        Open3.popen3('cat') do |stdin, stdout, stderr|
            stdin.puts "asdf"
            stdin.close
            cmd_output = stdout.gets
            stdout.close
            stderr.close
        end
        output_textarea.setString cmd_output
    end
    
    def logg text
        log_textarea.setString log_textarea.string + "\n" + text
    end
    
end

