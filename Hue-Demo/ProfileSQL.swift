//
//  ProfileSQL.swift
//  Hue
//
//  Created by alon tal on 16/03/2017.
//  Copyright © 2017 Omry Dabush. All rights reserved.
//

import Foundation

extension Profile{
    static let Profile_TABLE = "PROFILE"
    static let Profile_ProfileUID = "ProfileUID"
    static let Profile_profileName = "profileName"
    static let Profile_userName = "userName"
    static let Profile_profileImageURL = "profileImageURL"
    static let Profile_profileDiscription = "profileDiscription"
 

    static let userPosts_TABLE = "USERPOSTS"
    static let userPosts_ProfileUID = "ProfileUID"
    static let userPosts_ImageUID = "ImageUID"

    static let followers_TABLE = "FOLLOWERS"
    static let followers_ProfileUID = "ProfileUID"
    static let followers_followingme = "FollowingMe"
    
    static let following_TABLE = "FOLLOWING"
    static let following_ProfileUID = "ProfileUID"
    static let following_followafter = "FollowAfter"
    
    static func createTable(database:OpaquePointer?)->Bool{
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        
        let res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + Profile_TABLE + " ( " + Profile_ProfileUID + " TEXT PRIMARY KEY, "
            + Profile_profileName + " TEXT, "
            + Profile_userName + " TEXT, "
            + Profile_profileImageURL + " TEXT, "
            + Profile_profileDiscription + " TEXT) ", nil, nil, &errormsg);
  
        if(res != 0){
            print("error creating table");
            return false
        }
        
        let res1 = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + userPosts_TABLE + " ( " + userPosts_ProfileUID + " TEXT PRIMARY KEY, "
            + userPosts_ImageUID + " TEXT) ", nil, nil, &errormsg);
        
        if(res1 != 0){
            print("error creating table");
            return false
        }
        
        let res2 = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + followers_TABLE + " ( " + followers_ProfileUID + " TEXT PRIMARY KEY, "
            + followers_followingme + " TEXT) ", nil, nil, &errormsg);
        
        if(res2 != 0){
            print("error creating table");
            return false
        }
        
        let res3 = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS " + following_TABLE + " ( " + following_ProfileUID + " TEXT PRIMARY KEY, "
            + following_followafter + " TEXT) ", nil, nil, &errormsg);
        
        if(res3 != 0){
            print("error creating table");
            return false
        }
        
        return true
    }
    
    func addProfileToLocalDb(database:OpaquePointer?){
        var sqlite3_stmt: OpaquePointer? = nil
        //insert regular profile detailes
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO " + Profile.Profile_TABLE
            + "(" + Profile.Profile_ProfileUID + ","
            + Profile.Profile_profileName + ","
            + Profile.Profile_userName + ","
            + Profile.Profile_profileImageURL + ","
            + Profile.Profile_profileDiscription + ") VALUES (?,?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            
            let profileuid = self.profileUID?.cString(using: .utf8)
            let profilename = self.profileName?.cString(using: .utf8)
            let username = self.userName?.cString(using: .utf8)
            let imageurl = self.profileImageURL?.cString(using: .utf8)
            let profiledscription = self.profileDiscription?.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, profileuid,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, profilename,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, username,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 4, imageurl,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 5, profiledscription,-1,nil);

            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        //inserting the user posts to the local db
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO " + Profile.userPosts_TABLE
            + "(" + Profile.userPosts_ProfileUID + ","
            + Profile.userPosts_ImageUID + ") VALUES (?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            if let posts = self.userPosts{
            
            for pst in posts{
                sqlite3_bind_text(sqlite3_stmt, 1, profileUID,-1,nil);
                sqlite3_bind_text(sqlite3_stmt, 2, pst,-1,nil);
                }
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
            }
        }
        //inserting the user followers
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO " + Profile.followers_TABLE
            + "(" + Profile.followers_ProfileUID + ","
            + Profile.followers_followingme + ") VALUES (?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            if let followers = self.followers{
                
                for flwrs in followers{
                    sqlite3_bind_text(sqlite3_stmt, 1, profileUID,-1,nil);
                    sqlite3_bind_text(sqlite3_stmt, 2, flwrs,-1,nil);
                }
                
                if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                    print("new row added succefully")
                }
            }
        }
        
        //inserting who user is following
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO " + Profile.following_TABLE
            + "(" + Profile.following_ProfileUID + ","
            + Profile.following_followafter + ") VALUES (?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            if let followeing = self.following{
                
                for flwng in followeing{
                    sqlite3_bind_text(sqlite3_stmt, 1, profileUID,-1,nil);
                    sqlite3_bind_text(sqlite3_stmt, 2, flwng,-1,nil);
                }
                
                if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                    print("new row added succefully")
                }
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    static func getAllProfilesFromLocalDb(database:OpaquePointer?)->[Profile]{
        let profiles = [Profile]()
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"SELECT * from PROFILE;",-1,&sqlite3_stmt,nil) == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let profileuid =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,0))
                let profilename =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,1))
                let username =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,2))
                let imageurl =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,3))
                let profiledscription =  String(validatingUTF8:sqlite3_column_text(sqlite3_stmt,4))

                
                print("read from filter st: \(profileuid) \(profilename) \(username) \(imageurl) \(profiledscription)")
//                if (imageUrl != nil && imageUrl == ""){
//                    imageUrl = nil
//                }
//                let profile =  Profile(profileuid: profileuid!, profilename: profilename!, username: username!, profileimage: imageurl!, discription: profiledscription!, userposts: <#T##[String]#>, userfollowers: <#T##[String]#>, userfollowing: <#T##[String]#>)
                
             //   profiles.append(profile)
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return profiles
    }
    
}
