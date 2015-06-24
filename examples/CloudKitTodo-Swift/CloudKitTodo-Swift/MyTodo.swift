//
//  MyTodo.swift
//  CloudKitTodo-Swift
//
//  Created by king on 6/23/15.
//  Copyright (c) 2015 Example.com. All rights reserved.
//

import Foundation
import CloudKit
import YapDatabaseExtensions

@objc
public class MyTodo : MyDatabaseObject, NSCoding, NSCopying, DebugPrintable {
    
    // MARK: Types
    private struct SerializationKeys {
        static let version = "version"
        static let uuid = "uuid"
        static let title = "title"
        static let priority = "priority"
        static let isDone = "isDone"
        static let creationDate = "creationDate"
        static let lastModified = "lastModified"
    }
    
    public enum TodoPriority :Int {
        case Low = -1
        case Normal = 0
        case High = 1
    }
    
    // MARK: Properties
    
    public var uuid :String!
    
    public var title :String? = nil
    public var priority :TodoPriority = .Normal
    public var isDone :Bool = false
    
    public var creationDate :NSDate = NSDate()
    public var lastModified :NSDate = NSDate()
    
    // MARK: Initializers
    
    init(_ uuid :String?) {
        if let inUUID = uuid {
            self.uuid = inUUID
        }
        else {
            self.uuid = NSUUID().UUIDString
        }
        super.init()
    }
    
    convenience override init() {
        self.init(nil)
    }
    
    init?(record :CKRecord) {
        super.init()
        if record.recordType != "todo" {
            assertionFailure("Attempting to create todo from non-todo record") // For debug builds
            return nil  // For release builds
        }
        
        self.uuid = record.recordID.recordName
        let cloudKeys = self.allCloudProperties
        for cloudKey in cloudKeys {
            if cloudKey != "uuid" {
                setLocalValueFromCloudValue(record.objectForKey(cloudKey as! String), forCloudKey: cloudKey as! String)
            }
        }
    }
    
    // MARK: NSCoding
    
    public required init(coder aDecoder: NSCoder) {
        // The version can be used to handle on-the-fly upgrades to objects as they're decoded.
        // For more information, see the wiki article:
        // https://github.com/yapstudios/YapDatabase/wiki/Storing-Objects
        //	version = [decoder decodeIntForKey:k_version];
        
        self.uuid = aDecoder.decodeObjectForKey(SerializationKeys.uuid) as! String
        self.title = aDecoder.decodeObjectForKey(SerializationKeys.title) as? String
        self.priority = TodoPriority(rawValue: aDecoder.decodeIntegerForKey(SerializationKeys.priority))!
        self.isDone = aDecoder.decodeBoolForKey(SerializationKeys.isDone)
        self.creationDate = aDecoder.decodeObjectForKey(SerializationKeys.creationDate) as! NSDate
        self.lastModified = aDecoder.decodeObjectForKey(SerializationKeys.lastModified) as! NSDate
    }
    
    public func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeInteger(1, forKey: SerializationKeys.version)
        
        aCoder.encodeObject(self.uuid, forKey: SerializationKeys.uuid)
        aCoder.encodeObject(self.title, forKey: SerializationKeys.title)
        aCoder.encodeInteger(self.priority.rawValue, forKey: SerializationKeys.priority)
        aCoder.encodeBool(self.isDone, forKey: SerializationKeys.isDone)
        aCoder.encodeObject(self.creationDate, forKey: SerializationKeys.creationDate)
        aCoder.encodeObject(self.lastModified, forKey: SerializationKeys.lastModified)
    }
    
    // MARK: NSCopying
    
    public override func copyWithZone(zone: NSZone) -> AnyObject {
        var copy = super.copyWithZone(zone) as! MyTodo  // Be sure to invoke [MyDatabaseObject copyWithZone:] !
        copy.uuid = self.uuid
        copy.title = self.title
        copy.priority = self.priority
        copy.isDone = self.isDone
        copy.creationDate = self.creationDate
        copy.lastModified = self.lastModified
        return copy
    }
    
    // MARK: MyDatabaseObject Overrides
    
    override public class func storesOriginalCloudValues() -> Bool {
        return true
    }
    
    override public class func mappings_localKeyToCloudKey() -> NSMutableDictionary? {
        let mappings_localKeyToCloudKey = super.mappings_localKeyToCloudKey()
        mappings_localKeyToCloudKey["creationDate"] = "created"
        return mappings_localKeyToCloudKey
    }

    public override func cloudValueForCloudKey(key: String!) -> AnyObject! {
        
        // Override me if needed.
        // For example:
        //
        // if key == "color" {
        //     // We store UIColor in the cloud as a string (r,g,b,a)
        //     return ConvertUIColorToNSString(self.color)
        // }
        // else {
        //     return super.cloudValueForCloudKey(key)
        // }
        
        return super.cloudValueForCloudKey(key)
    }
    
    public override func setLocalValueFromCloudValue(cloudValue: AnyObject!, forCloudKey cloudKey: String!) {
        
        // Override me if needed.
        // For example:
        //
        // if key == "color" {
        //     // We store UIColor in the cloud as a string (r,g,b,a)
        //     self.color = ConvertNSStringToUIColor(cloudValue as! String)
        // }
        // else {
        //     return super.setLocalValueForCloudValue(cloudValue, cloudKey:cloudKey)
        // }

        return super.setLocalValueFromCloudValue(cloudValue, forCloudKey: cloudKey)
    }
    
    // MARK: KVO overrides
    
    public override func setNilValueForKey(key: String) {
        if key == "priority" {
            self.priority = .Normal
        }
        if key == "isDone" {
            self.isDone = false
        }
        else {
            super.setNilValueForKey(key)
        }
    }
    
    // MARK: DebugPrintable
    
    public override var debugDescription: String {
        return "Todo: " + (self.title ?? "<No Title>") + "(UUID: \(self.uuid))"
    }
    
}

