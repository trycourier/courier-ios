//
//  SwiftUIViewController.swift
//  Example
//
//  Created by Michael Miller on 2/6/25.
//

import SwiftUI
import Courier_iOS

struct SwiftUIViewController: View {
    var body: some View {
        CourierInboxView { message, index in
            HStack(alignment: .top, spacing: 12) {
                // Indicator for Unread Messages (Blue dot)
                if !message.isRead {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 10, height: 10)
                        .padding(.top, 6)
                } else {
                    // Empty space to align with unread indicator
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 10, height: 10)
                        .padding(.top, 6)
                }
                
                // Message Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.title ?? "No Title")
                        .font(.headline)
                        .fontWeight(message.isRead ? .regular : .bold) // Bold if unread
                        .foregroundColor(.primary)
                        .lineLimit(1) // Limit to one line

                    Text(message.subtitle ?? "No Subtitle")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2) // Limit to two lines
                }
                
                Spacer() // Push content to the left
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.white) // Consistent background
            .contentShape(Rectangle()) // Make the whole area tappable
            .onTapGesture {
                // Toggle read/unread on tap
                if message.isRead {
                    message.markAsUnread()
                } else {
                    message.markAsRead()
                }
            }
            .overlay(
                Divider()
                    .padding(.leading, message.isRead ? 16 : 34), // Align divider with content
                alignment: .bottom
            )
        }
    }
}
