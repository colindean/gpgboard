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
        @gpg_path = `which gpg`.chomp
        logg "initialized #{@gpg_path} with:\n #{`#{@gpg_path} --version`} "
        load_private_keys
    end
    
    def load_private_keys
        cmd_output = `#{@gpg_path} --no-tty -K`
        keys = cmd_output.split("\n").select{|l|l.match(/^sec/)}.collect{|m|m.match(/\d{4}\w{1}\/[\d\w]{8}/).to_s.split("/")[1]}
        @privkeys_popup_button = PopUpButtonWithArray.new(privkeys_popup, keys) #to setup the button's options
    end
    
    
    def sign_text sender
        key = "0x" + @privkeys_popup_button.get_selected
        logg "signing text with key #{key}"
        do_gpg_cmd("--clearsign --local-user #{key}")
    end
    
    def encrypt_text sender
        recipient = recipient_text.stringValue
        logg "encrypting for #{recipient}..."
        do_gpg_cmd("--armor --encrypt -r #{recipient}")
    end
    
    def decrypt_text sender
        key = "0x" + @privkeys_popup_button.get_selected
        logg "decrypting text as #{key}"
        do_gpg_cmd("--decrypt --local-user #{key}")
    end
    
    def verify_text sender
        logg "verifying text..."
        do_gpg_cmd("--verify")
    end
    
    def do_gpg_cmd cmd
        do_gpg_cmd_nstask cmd
    end

    def do_gpg_cmd_nstask cmd
        Dispatch::Queue.concurrent.async do
            fcmd = "--no-tty " + cmd
            task = NSTask.alloc.init
            task.setLaunchPath(@gpg_path)
            task.setArguments(fcmd.split(" "))

            task.arguments.each {|a| puts "ARG: [#{a}]" }

            inpipe = NSPipe.pipe
            outpipe = NSPipe.pipe
            errpipe = NSPipe.pipe

            task.setStandardOutput(outpipe)
            task.setStandardInput(inpipe)
            task.setStandardError(errpipe)

            output = outpipe.fileHandleForReading
            errput = errpipe.fileHandleForReading
            input = inpipe.fileHandleForWriting

            task.launch

            input.writeData input_text.dataUsingEncoding(NSUTF8StringEncoding)
            input.closeFile

            sleep 5

            task.terminate

            outdata = output.readDataToEndOfFile
            errdata = errput.readDataToEndOfFile
            output.closeFile
            errput.closeFile

            outstring = NSString.alloc.initWithData(outdata, :encoding => NSUTF8StringEncoding)
            errstring = NSString.alloc.initWithData(errdata, :encoding => NSUTF8StringEncoding)

            output_text outstring
            logg errstring
        end
    end

    def do_gpg_cmd_ruby cmd
        gpg = "#{@gpg_path} --no-tty "
        cmd_output = ''
        logg "executing [#{cmd}]"
        Dispatch::Queue.concurrent.async do
            logg "new thread starting"
            Open3.popen3(gpg + cmd) do |stdin, stdout, stderr|
                stdin.write input_text
                stdin.close
                cmd_output = stdout.read
                output_text cmd_output
                stdout.close
                logg stderr.read
                stderr.close
            end
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

