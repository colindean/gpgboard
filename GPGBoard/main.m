//
//  main.m
//  GPGBoard
//
//  Created by Colin Dean on 3/8/13.
//  Copyright (c) 2013 Colin Dean. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
    return macruby_main("rb_main.rb", argc, argv);
}
