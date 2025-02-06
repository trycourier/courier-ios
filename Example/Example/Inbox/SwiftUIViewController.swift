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
        CourierInboxView({ message, index in
            VStack(alignment: .leading, spacing: 8) {
                Text(message.title ?? "No Title")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(message.subtitle ?? "No Subtitle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(message.isRead ? Color.gray.opacity(0.1) : Color.blue.opacity(0.2))
            .cornerRadius(10)
            .shadow(radius: 1)
        })
    }
}
