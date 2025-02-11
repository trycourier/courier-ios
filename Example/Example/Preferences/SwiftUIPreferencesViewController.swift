//
//  SwiftUIPreferencesViewController.swift
//  Example
//
//  Created by Michael Miller on 2/10/25.
//

import SwiftUI
import Courier_iOS

struct SwiftUIPreferencesViewController: View {
    var body: some View {
        CourierPreferencesView { view, topic, section, index in
            CustomTopicListItemView(topic: topic) {
                view.showSheet(topic: topic)
            }
        }
    }
}

struct CustomTopicListItemView: View {
    var topic: CourierUserPreferencesTopic
    var onClick: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(topic.topicName)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .lineLimit(nil)

                Text(topic.status == .optedOut ? "Off" : "On")
                    .font(.system(size: 16, weight: .regular, design: .monospaced))
                    .lineLimit(nil)
            }
            Spacer()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            onClick()
        }
    }
}
