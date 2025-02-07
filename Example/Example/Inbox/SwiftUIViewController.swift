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
                Circle()
                    .fill(Color.gray)
                    .frame(width: 32, height: 32)
                    .padding(.top, 8)
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.title ?? "No Title")
                        .font(.headline)
                        .fontWeight(message.isRead ? .regular : .bold)
                        .foregroundColor(.primary)
                    Text(message.subtitle ?? "No Subtitle")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .contentShape(Rectangle())
            .background(!message.isRead ? Color.blue.opacity(0.25) : Color.clear)
            .onTapGesture {
                message.isRead ? message.markAsUnread() : message.markAsRead()
            }
        }
    }
}
