//
//  DataManager.swift
//  todo-animations
//
//  Created by Mohamed Dabbour on 12/8/20.
//

import Foundation
///Model Used to save Simple data to the disk using a simple file
class DataManager {
    
    //TODO:get document directory
    static fileprivate func getDocumentDirectory() -> URL{
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            return url;
        }else{
            fatalError("Unable to access document directory!")
        }
        
    }
    
    //TODO:Save any kind of codable objects
    static func save<T:Encodable> (_ object:T,with fileName:String){
        //Url that points to a file => {Path}/file.exe for example
        let url = getDocumentDirectory().appendingPathComponent(fileName, isDirectory: false)
        
        let encoder = JSONEncoder()
        
        do {
            let data = try encoder.encode(object)
            if FileManager.default.fileExists(atPath: url.path) {
                try FileManager.default.removeItem(at: url)
            }
            FileManager.default.createFile(atPath: url.path, contents: data, attributes: nil)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    
    //TODO:Load any kind of codable objects
    static func load<T:Decodable> (_ fileName:String,with type:T.Type) -> T{
        let url = getDocumentDirectory().appendingPathComponent(fileName,isDirectory: false)
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("File Not found at path \(url.path)")
        }
        if let data = FileManager.default.contents(atPath: url.path) {
            do{
                let model = try JSONDecoder().decode(type, from: data)
                return model
            }catch{
                fatalError(error.localizedDescription)
            }
        }else{
            fatalError("data is not available at path \(url.path)")
        }
    }
    
    //TODO:Load data from file
    static func loadData (_ fileName:String) -> Data?{
        let url = getDocumentDirectory().appendingPathComponent(fileName,isDirectory: false)
        if !FileManager.default.fileExists(atPath: url.path) {
            fatalError("File Not found at path \(url.path)")
        }
        if let data = FileManager.default.contents(atPath: url.path) {
           return data
        }else{
            fatalError("data is not available at path \(url.path)")
        }
    }
    
    //TODO:Load all files from a directory
    static func loadAll<T:Decodable> (_ type:T.Type) -> [T]{
        do{
            let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentDirectory().path)
            
            var modelObjects = [T]()
            
            for fileName in files {
                modelObjects.append(load(fileName, with: type))
            }
            
            return modelObjects
        }catch{
            fatalError("Couldn't load any files")
        }
    }
    
    
    //TODO:Delete a file
    static func delete(_ fileName:String){
        let url = getDocumentDirectory().appendingPathComponent(fileName,isDirectory: false)
        
        if FileManager.default.fileExists(atPath: url.path) {
            do{
                try FileManager.default.removeItem(at: url)
            }catch{
                fatalError(error.localizedDescription)
            }
        }
    }
}
