//
//  InboxMessageSet.swift
//  Courier_iOS
//
//  Created by Michael Miller on 2/14/25.
//

public struct InboxMessageSet: Codable {
    internal(set) public var messages: [InboxMessage]
    internal(set) public var totalCount: Int
    internal(set) public var canPaginate: Bool
    internal(set) public var paginationCursor: String?
}

public struct InboxMessageDataSet: Codable {
    
    internal(set) public var messages: [InboxMessage]
    internal(set) public var totalCount: Int
    internal(set) public var canPaginate: Bool
    internal(set) public var paginationCursor: String?

    public init(
        messages: [InboxMessage] = [],
        totalCount: Int = 0,
        canPaginate: Bool = false,
        paginationCursor: String? = nil
    ) {
        self.messages = messages
        self.totalCount = totalCount
        self.canPaginate = canPaginate
        self.paginationCursor = paginationCursor
    }
    
}
