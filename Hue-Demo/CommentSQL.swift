//
//  CommentSQL.swift
//  Hue
//
//  Created by alon tal on 16/03/2017.
//  Copyright © 2017 Omry Dabush. All rights reserved.
//

import Foundation


extension Comment{
    static let Comment_TABLE = "COMMENT"
    static let Image_UID = "ImageUID"
    static let Comment_commentedProfileImage = "commentedProfileImage"
    static let Comment_ProfileName = "commentedProfileName"
    static let Comment_comment = "comment"

    
    
    static func createTable(database:OpaquePointer?)->Bool{
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + Comment_TABLE + " ( " + Image_UID + " TEXT PRIMARY KEY, "
            + Comment_commentedProfileImage + " TEXT, "
            + Comment_ProfileName + " TEXT, "
            + Comment_comment + " TEXT) ", nil, nil, &errormsg);
        
        if(res != 0){
            print("error creating table");
            return false
        }
        
        return true
    }
    
    func addCommentToLocalDb(database:OpaquePointer?){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO " + Comment.Comment_TABLE
            + "(" + Comment.Image_UID + ","
            + Comment.Comment_commentedProfileImage + ","
            + Comment.Comment_ProfileName + ","
            + Comment.Comment_comment + ") VALUES (?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            
            let imId = self.imageUID?.cString(using: .utf8)
            let profileimage = self.commentedProfileImage?.cString(using: .utf8)
            let profilename = self.commentedProfileName?.cString(using: .utf8)
            let comm = self.comment?.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, imId,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, profileimage,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, profilename,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 4, comm,-1,nil);

            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func getAllImagesFromLocalDb(database:OpaquePointer?)->[Comment]{
        var comments = [Comment]()
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"SELECT * from COMMENT;",-1,&sqlite3_stmt,nil) == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                
                let imId =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,0))
                let profileimage =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,1))
                let profilename =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,2))
                let comm =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,3))

                
                
                print("read from filter st: \(imId) \(profileimage) \(profilename) \(comm)")
//                if (imageUrl != nil && imageUrl == ""){
//                    imageUrl = nil
//                }
                let comment = Comment(imageuid: imId!, commprofileImage: profileimage!, commprofileName: profilename!, comm: comm!)
                
                comments.append(comment)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return comments
    }
    
}
