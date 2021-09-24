//
//  AccountDocument.swift
//  OpenSesame
//
//  Created by Ethan Lipnik on 9/23/21.
//

import SwiftUI
import UniformTypeIdentifiers

struct AccountDocument: FileDocument, Codable {
    
    // MARK: - Variables
    var domain: String
    var website: String
    var username: String
    var password: String
    var otpAuth: String?
    var notes: String
    var dateAdded: Date
    var lastModified: Date?
    
    // MARK: - Inits
    init(domain: String, website: String, username: String, password: String, otpAuth: String? = nil, notes: String, dateAdded: Date, lastModified: Date? = nil) {
        self.domain = domain
        self.website = website
        self.username = username
        self.password = password
        self.otpAuth = otpAuth
        self.notes = notes
        self.dateAdded = dateAdded
        self.lastModified = lastModified
    }
    
    enum CodingKeys: CodingKey {
        case domain
        case website
        case username
        case password
        case otpAuth
        case notes
        case dateAdded
        case lastModified
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateFormatter = ISO8601DateFormatter()
        
        self.domain = try container.decode(String.self, forKey: .domain)
        self.website = try container.decode(String.self, forKey: .website)
        self.username = try container.decode(String.self, forKey: .username)
        self.password = try container.decode(String.self, forKey: .password)
        self.otpAuth = try? container.decode(String.self, forKey: .otpAuth)
        self.notes = try container.decode(String.self, forKey: .notes)
        
        self.dateAdded = dateFormatter.date(from: try container.decode(String.self, forKey: .dateAdded)) ?? Date()
        if let lastModified = try? container.decode(String.self, forKey: .lastModified) {
            self.lastModified = dateFormatter.date(from: lastModified)
        }
    }
    
    init(_ account: Account) throws {
        self.domain = account.domain ?? ""
        self.website = account.url ?? ""
        self.username = account.username ?? ""
        
        self.password = try CryptoSecurityService.decrypt(account.password!) ?? ""
        
        self.otpAuth = account.otpAuth
        self.notes = account.notes ?? ""
        self.dateAdded = account.dateAdded ?? Date()
        self.lastModified = account.lastModified
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self = try JSONDecoder().decode(AccountDocument.self, from: data)
    }
    
    func encode(to encoder: Encoder) throws {
        let dateFormatter = ISO8601DateFormatter()
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(domain, forKey: .domain)
        try container.encode(website, forKey: .website)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
        try container.encode(otpAuth, forKey: .otpAuth)
        try container.encode(notes, forKey: .notes)
        try container.encode(dateFormatter.string(from: dateAdded), forKey: .dateAdded)
        if let lastModified = lastModified {
            try? container.encode(dateFormatter.string(from: lastModified), forKey: .lastModified)
        }
    }
    
    static var readableContentTypes: [UTType] { [.accountDocument] }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)
        
        return .init(regularFileWithContents: data)
    }
}
