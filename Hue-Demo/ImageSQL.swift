//
//  ImageSQL.swift
//  Hue
//
//  Created by alon tal on 16/03/2017.
//  Copyright © 2017 Omry Dabush. All rights reserved.
//

import Foundation

extension Image{
    static let Image_TABLE = "IMAGE"
    static let Image_UID = "ImageUID"
    static let Image_Url = "imageURL"
    static let Image_Title = "imageTitle"
    static let Image_numOfLikes = "numOfLikes"
    static let Image_uploadDate = "uploadDate"
    static let Image_ownerUID = "ownerUID"
    static let Image_comments = "comments"
    
    
    static func createTable(database:OpaquePointer?)->Bool{
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + Image_TABLE + " ( " + Image_UID + " TEXT PRIMARY KEY, "
            + Image_Url + " TEXT, "
            + Image_Title + " TEXT, "
            + Image_numOfLikes + " TEXT, "
            + Image_uploadDate + " TEXT, "
            + Image_ownerUID + " TEXT) ", nil, nil, &errormsg);
            
        
        
        if(res != 0){
            print("error creating table");
            return false
        }
        
        return true
    }
    
    func addStudentToLocalDb(database:OpaquePointer?){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO " + Image.Image_TABLE
            + "(" + Image.Image_UID + ","
            + Image.Image_Url + ","
            + Image.Image_Title + ","
            + Image.Image_numOfLikes + ","
            + Image.Image_uploadDate + ","
            + Image.Image_ownerUID + ") VALUES (?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
        
            
            
            let id = self.imageUID?.cString(using: .utf8)
            var imageUrl = "".cString(using: .utf8)
            let title = self.imageTitle?.cString(using: .utf8)
            let numoflikes = self.numOfLikes
            let date = self.uploadDate
            let owneruid = self.OwnerUID?.cString(using: .utf8)
            
            if self.imageURL != nil {
                imageUrl = self.imageURL!.cString(using: .utf8)
            }
            
            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, imageUrl,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, title,-1,nil);
            sqlite3_bind_int(sqlite3_stmt, 4, numoflikes as! Int32);
            if (uploadDate == nil){
                uploadDate = NSDate()
            }
            sqlite3_bind_double(sqlite3_stmt, 5, (date?.dateToSQL())!);
            
            sqlite3_bind_text(sqlite3_stmt, 6, owneruid,-1,nil);
                        
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func getAllImagesFromLocalDb(database:OpaquePointer?)->[Image]{
        var images = [Image]()
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"SELECT * from IMAGE;",-1,&sqlite3_stmt,nil) == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let imId =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,0))
                var imageUrl =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,1))
                let title =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,2))
               // let numoflikes =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,3))
                
                let numoflikes = NSNumber(integerLiteral: Int(sqlite3_column_int(sqlite3_stmt, 3)))
                
                let uploaddate = NSDate(timeIntervalSince1970: sqlite3_column_double(sqlite3_stmt, 4))
                let owneruid = String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,5))
                
                var comments : [String : Comment]?
                if (sqlite3_prepare_v2(database,"SELECT * from COMMENTS WHERE imageUID = imId ;",-1,&sqlite3_stmt,nil) == SQLITE_OK){
                    while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                        let imId =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,0))
                        let commentedProfileImage =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,1))
                        let commentedProfileName =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,2))
                        let comment =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,3))

                        comments?[imId!] = Comment(imageuid: imId!, commprofileImage: commentedProfileImage!, commprofileName: commentedProfileName!, comm: comment!)
                    }
                }
            
                
                print("read from filter st: \(imId) \(imageUrl) \(title) \(numoflikes) \(uploaddate) \(owneruid)")
                if (imageUrl != nil && imageUrl == ""){
                    imageUrl = nil
                }
                let image = Image(imageuid : imId!, url: imageUrl!, title: title!, nOfLikes: numoflikes, Date: uploaddate, owner: owneruid!, comm: comments)
                
                images.append(image)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return images
    }
    
}
