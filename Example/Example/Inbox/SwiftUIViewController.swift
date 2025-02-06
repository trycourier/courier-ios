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
                    .fill(message.isRead ? Color.blue : Color.clear)
                    .frame(width: 10, height: 10)
                    .padding(.top, 6)
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
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
            .onTapGesture {
                message.isRead ? message.markAsUnread() : message.markAsRead()
            }
        }
    }
}
