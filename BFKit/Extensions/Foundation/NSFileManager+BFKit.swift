//
//  NSFileManager+BFKit.swift
//  BFKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Fabrizio Brancati. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

// MARK: - Global variables -

enum DirectoryType : Int
{
    case MainBundle
    case Library
    case Documents
    case Cache
}

extension NSFileManager
{
    // MARK: - Class functions -
    
    static func readTextFile(var file: String, ofType: String) -> String?
    {
        return String(contentsOfFile: NSBundle.mainBundle().pathForResource(file, ofType: ofType)!, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    static func saveArrayToPath(directory: DirectoryType, filename: String, array: Array<AnyObject>) -> Bool
    {
        var finalPath: String
        
        switch directory
        {
        case .MainBundle:
            finalPath = self.getBundlePathForFile(filename)
        case .Library:
            finalPath = self.getLibraryDirectoryForFile(filename)
        case .Documents:
            finalPath = self.getDocumentsDirectoryForFile(filename)
        case .Cache:
            finalPath = self.getCacheDirectoryForFile(filename)
        default:
            finalPath = self.getBundlePathForFile(filename)
        }
        
        return NSKeyedArchiver.archiveRootObject(array, toFile: finalPath)
    }
    
    static func loadArrayToPath(directory: DirectoryType, filename: String) -> Bool
    {
        var finalPath: String
        
        switch directory
        {
        case .MainBundle:
            finalPath = self.getBundlePathForFile(filename)
        case .Library:
            finalPath = self.getLibraryDirectoryForFile(filename)
        case .Documents:
            finalPath = self.getDocumentsDirectoryForFile(filename)
        case .Cache:
            finalPath = self.getCacheDirectoryForFile(filename)
        default:
            finalPath = self.getBundlePathForFile(filename)
        }
        
        if(NSKeyedUnarchiver.unarchiveObjectWithFile(finalPath) != nil)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    static func getBundlePathForFile(file: String) -> String
    {
        let fileExtension = file.pathExtension
        return NSBundle.mainBundle().pathForResource(file.stringByReplacingOccurrencesOfString(String(format: ".%@", file), withString: ""), ofType: fileExtension)!
    }
    
    static func getDocumentsDirectoryForFile(file: String) -> String
    {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        return documentsDirectory.stringByAppendingPathComponent(String(format: "%@/", file))
    }
    
    static func getLibraryDirectoryForFile(file: String) -> String
    {
        let libraryDirectory = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)[0] as! String
        return libraryDirectory.stringByAppendingPathComponent(String(format: "%@/", file))
    }
    
    static func getCacheDirectoryForFile(file: String) -> String
    {
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)[0] as! String
        return cacheDirectory.stringByAppendingPathComponent(String(format: "%@/", file))
    }
    
    static func fileSize(file: String, fromDirectory directory: DirectoryType) -> NSNumber?
    {
        if count(file) != 0
        {
            var path: String
            
            switch directory
            {
            case .MainBundle:
                path = self.getBundlePathForFile(file)
            case .Library:
                path = self.getLibraryDirectoryForFile(file)
            case .Documents:
                path = self.getDocumentsDirectoryForFile(file)
            case .Cache:
                path = self.getCacheDirectoryForFile(file)
            default:
                path = self.getBundlePathForFile(file)
            }
            
            if(NSFileManager.defaultManager().fileExistsAtPath(path))
            {
                if let fileAttributes = NSFileManager.defaultManager().attributesOfItemAtPath(file, error: nil)
                {
                    return fileAttributes[NSFileSize] as? NSNumber
                }
            }
        }
        
        return nil
    }
    
    static func deleteFile(file: String, fromDirectory directory: DirectoryType) -> Bool
    {
        if count(file) != 0
        {
            var path: String
            
            switch directory
            {
            case .MainBundle:
                path = self.getBundlePathForFile(file)
            case .Library:
                path = self.getLibraryDirectoryForFile(file)
            case .Documents:
                path = self.getDocumentsDirectoryForFile(file)
            case .Cache:
                path = self.getCacheDirectoryForFile(file)
            default:
                path = self.getBundlePathForFile(file)
            }
            
            if(NSFileManager.defaultManager().fileExistsAtPath(path))
            {
                return NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
            }
        }
        
        return false
    }
    
    static func moveLocalFile(file: String, fromDirectory origin: DirectoryType, toDirectory destination: DirectoryType, withFolderName folderName: String?) -> Bool
    {
        var originPath: String
        
        switch origin
        {
        case .MainBundle:
            originPath = self.getBundlePathForFile(file)
        case .Library:
            originPath = self.getLibraryDirectoryForFile(file)
        case .Documents:
            originPath = self.getDocumentsDirectoryForFile(file)
        case .Cache:
            originPath = self.getCacheDirectoryForFile(file)
        default:
            originPath = self.getBundlePathForFile(file)
        }
        
        var destinationPath: String = ""
        if folderName != nil
        {
            destinationPath = String(format: "%@/%@", destinationPath, folderName!)
        }
        else
        {
            destinationPath = file
        }
        
        switch destination
        {
        case .MainBundle:
            destinationPath = self.getBundlePathForFile(destinationPath)
        case .Library:
            destinationPath = self.getLibraryDirectoryForFile(destinationPath)
        case .Documents:
            destinationPath = self.getDocumentsDirectoryForFile(destinationPath)
        case .Cache:
            destinationPath = self.getCacheDirectoryForFile(destinationPath)
        default:
            destinationPath = self.getBundlePathForFile(destinationPath)
        }
        
        if folderName != nil
        {
            let folderPath: String = String(format: "%@/%@", destinationPath, folderName!)
            if !NSFileManager.defaultManager().fileExistsAtPath(originPath)
            {
                NSFileManager.defaultManager().createDirectoryAtPath(folderPath, withIntermediateDirectories: false, attributes: nil, error: nil)
            }
        }
        
        var copied: Bool = false, deleted: Bool = false
        if NSFileManager.defaultManager().fileExistsAtPath(originPath)
        {
            if NSFileManager.defaultManager().copyItemAtPath(originPath, toPath: destinationPath, error: nil)
            {
                copied = true
            }
        }
        
        if destination != .MainBundle
        {
            if NSFileManager.defaultManager().fileExistsAtPath(originPath)
            {
                if NSFileManager.defaultManager().removeItemAtPath(originPath, error: nil)
                {
                    deleted = true
                }
            }
        }
        
        if copied && deleted
        {
            return true
        }
        return false
    }
    
    static func moveLocalFile(file: String, fromDirectory origin: DirectoryType, toDirectory destination: DirectoryType) -> Bool
    {
        return self.moveLocalFile(file, fromDirectory: origin, toDirectory: destination, withFolderName: nil)
    }
    
    static func duplicateFileAtPath(origin: String, toNewPath destination: String) -> Bool
    {
        if NSFileManager.defaultManager().fileExistsAtPath(origin)
        {
            return NSFileManager.defaultManager().copyItemAtPath(origin, toPath: destination, error: nil)
        }
        return false
    }
    
    static func renameFileFromDirectory(origin: DirectoryType, atPath path: String, withOldName oldName: String, andNewName newName: String) -> Bool
    {
        var originPath: String
        
        switch origin
        {
        case .MainBundle:
            originPath = self.getBundlePathForFile(path)
        case .Library:
            originPath = self.getLibraryDirectoryForFile(path)
        case .Documents:
            originPath = self.getDocumentsDirectoryForFile(path)
        case .Cache:
            originPath = self.getCacheDirectoryForFile(path)
        default:
            originPath = self.getBundlePathForFile(path)
        }
        
        if NSFileManager.defaultManager().fileExistsAtPath(originPath)
        {
            let newNamePath: String = originPath.stringByReplacingOccurrencesOfString(oldName, withString: newName)
            if NSFileManager.defaultManager().copyItemAtPath(originPath, toPath: newNamePath, error: nil)
            {
                if NSFileManager.defaultManager().removeItemAtPath(originPath, error: nil)
                {
                    return true
                }
            }
        }
        return false
    }
    
    static func getSettings(settings: String, objectForKey: String) -> AnyObject?
    {
        var path: String = self.getLibraryDirectoryForFile(String(format: "%@-Settings.plist", settings))
        var loadedPlist: NSMutableDictionary = NSMutableDictionary(contentsOfFile: path)!
        
        if NSFileManager.defaultManager().fileExistsAtPath(path)
        {
            path = NSBundle.mainBundle().pathForResource(String(format: "%@-Settings", settings), ofType: "plist")!
            self.moveLocalFile(String(format: "%@-Settings.plist", settings), fromDirectory: .MainBundle, toDirectory: .Library, withFolderName: "")
            loadedPlist = NSMutableDictionary(contentsOfFile: path)!
        }
        
        return loadedPlist[objectForKey]
    }
    
    static func setSettings(settings: String, object: AnyObject, forKey objKey: String) -> Bool
    {
        var path: String = self.getLibraryDirectoryForFile(String(format: "%@-Settings.plist", settings))
        var loadedPlist: NSMutableDictionary = NSMutableDictionary(contentsOfFile: path)!
        
        if NSFileManager.defaultManager().fileExistsAtPath(path)
        {
            path = NSBundle.mainBundle().pathForResource(String(format: "%@-Settings", settings), ofType: "plist")!
            self.moveLocalFile(String(format: "%@-Settings.plist", settings), fromDirectory: .MainBundle, toDirectory: .Library, withFolderName: "")
            loadedPlist = NSMutableDictionary(contentsOfFile: path)!
        }
        
        loadedPlist[objKey] = object
        
        return loadedPlist.writeToFile(path, atomically: true)
    }
    
    static func setAppSettingsForObject(object: AnyObject, forKey objKey: String) -> Bool
    {
        return self.setSettings(APP_NAME, object: object, forKey: objKey)
    }
    
    static func getAppSettingsForObjectWithKey(objKey: String) -> AnyObject?
    {
        return self.getSettings(APP_NAME, objectForKey: objKey)
    }
}
