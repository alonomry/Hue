//
//  ModelSql.swift
//  Hue
//
//  Created by alon tal on 16/03/2017.
//  Copyright © 2017 Omry Dabush. All rights reserved.
//

import Foundation

extension String {
    public init?(validatingUTF8 cString: UnsafePointer<UInt8>) {
        if let (result, _) = String.decodeCString(cString, as: UTF8.self,
                                                  repairingInvalidCodeUnits: false) {
            self = result
        }
        else {
            return nil
        }
    }
}


class ModelSQL{
    var database: OpaquePointer? = nil
    
    init?(){
        let dbFileName = "HueSql.db"
        if let dir = FileManager.default.urls(for: .documentDirectory, in:
            .userDomainMask).first{
            let path = dir.appendingPathComponent(dbFileName)
            
            if sqlite3_open(path.absoluteString, &database) != SQLITE_OK {
                print("Failed to open db file: \(path.absoluteString)")
                return nil
            }
        }
        if Profile.createTable(database: database) == false{
            return nil
        }
        if Image.createTable(database: database) == false{
            return nil
        }
        if Comment.createTable(database: database) == false{
            return nil
        }

//        if LastUpdateTable.createTable(database: database) == false{
//            return nil
//        }
    }
}

