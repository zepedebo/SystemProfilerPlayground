#!/usr/bin/swift
import Cocoa

let lsProc = Process()
let wcProc = Process()
 wcProc.launchPath = "/usr/bin/wc" 
 lsProc.launchPath = "/bin/ls"
let lsOutPipe = Pipe()
let wcOutPipe = Pipe() 
lsProc.standardOutput = lsOutPipe 
wcProc.standardInput = lsOutPipe 
wcProc.arguments = ["-l"] 
wcProc.standardOutput = wcOutPipe
if(CommandLine.arguments.count > 1)	{
 lsProc.arguments = [CommandLine.arguments[1]]
} 
lsProc.launch() 
wcProc.launch() 
lsProc.waitUntilExit() 
wcProc.waitUntilExit()

let data = wcOutPipe.fileHandleForReading.readDataToEndOfFile()
let stringData = String(data: data, encoding: String.Encoding.utf8)

print("File count = \(stringData!)")


