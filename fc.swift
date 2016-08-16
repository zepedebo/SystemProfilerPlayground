#!/usr/bin/swift
import Cocoa

let lsTask = Task()
let wcTask = Task()

wcTask.launchPath = "/usr/bin/wc"
lsTask.launchPath = "/bin/ls"
let lsOutPipe = Pipe()
let wcOutPipe = Pipe()
lsTask.standardOutput = lsOutPipe
wcTask.standardInput = lsOutPipe
wcTask.arguments = ["-l"]
wcTask.standardOutput = wcOutPipe
if(Process.arguments.count > 1)	{
	lsTask.arguments = [Process.arguments[1]]
}
lsTask.launch()
wcTask.launch()
lsTask.waitUntilExit()
wcTask.waitUntilExit()

let data = wcOutPipe.fileHandleForReading.readDataToEndOfFile()
let stringData = String(data: data, encoding: String.Encoding.utf8)

print("File count = \(stringData!)")


