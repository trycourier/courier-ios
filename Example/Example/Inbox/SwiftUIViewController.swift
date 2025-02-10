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
            CustomInboxListItemView(message: message) {
                message.isRead ? message.markAsUnread() : message.markAsRead()
            }
        }
    }
}

struct CustomInboxListItemView: View {
    var message: InboxMessage
    var onClick: () -> Void

    @State private var isHighlighted = false

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let imageUrl = message.data?["image"] as? String, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray
                            .frame(width: 48, height: 64)
                            .opacity(message.isRead ? 0.5 : 1)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 64)
                            .clipped()
                            .opacity(message.isRead ? 0.5 : 1)
                    case .failure:
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 64)
                            .opacity(message.isRead ? 0.5 : 1)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 64)
                    .opacity(message.isRead ? 0.5 : 1)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(message.title ?? "Title")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(Color.primary.opacity(message.isRead ? 0.5 : 1))
                    .lineLimit(nil)

                Text(message.subtitle ?? "Subtitle")
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                    .foregroundColor(Color.gray.opacity(message.isRead ? 0.5 : 1))
                    .lineLimit(nil)
            }

            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(isHighlighted ? Color.blue.opacity(0.3) : Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            onClick()
        }
    }
}
