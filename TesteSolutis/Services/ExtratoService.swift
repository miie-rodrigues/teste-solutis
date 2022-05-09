//
//  ExtratoService.swift
//  TesteSolutis
//
//  Created by Virtual Machine on 14/04/22.
//

import Foundation

protocol ExtratoServiceDelegate {
    func extratoSuccess(extratoList: [Extrato])
    func extratoError(message: String)
}

class ExtratoService {
    var delegate: ExtratoServiceDelegate?
    
    let apiUrl = "https://api.mobile.test.solutis.xyz/";
    
    func getExtract(token: String) {
        let url = apiUrl + "extrato"
        performRequest(url: url, token: token)
    }
    
    func performRequest(url: String, token: String) {
        if let url = URL(string: url) {
            let session = URLSession(configuration: .default)
            var request = URLRequest(url: url)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(token, forHTTPHeaderField: "token")
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request) { data, response, error in
                if error != nil {
                    self.delegate?.extratoError(message: "Ocorreu um erro desconhecido")
                    return
                }
                
                if (response as! HTTPURLResponse).statusCode > 299 {
                    self.delegate?.extratoError(message: "Ocorreu um erro desconhecido")
                    return
                }
                
                if let safeData = data {
                    if let extratoList = self.parseJson(safeData) {
                        self.delegate?.extratoSuccess(extratoList: extratoList)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJson(_ data: Data) -> [Extrato]? {
        do {
            let extratoList = try JSONDecoder().decode([Extrato].self, from: data)
           
            return extratoList
        } catch {
            delegate?.extratoError(message: error.localizedDescription)
            return nil
        }
    }
}
