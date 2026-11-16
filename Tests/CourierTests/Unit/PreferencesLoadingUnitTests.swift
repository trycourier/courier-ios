//
//  PreferencesLoadingUnitTests.swift
//  Courier_iOS
//

import Foundation
import XCTest
@testable import Courier_iOS

@MainActor
class PreferencesLoadingUnitTests: XCTestCase {

    private struct BrandUnavailable: Error {}

    private func topic(_ id: String, section: String) -> CourierUserPreferencesTopic {
        CourierUserPreferencesTopic(
            defaultStatus: "OPTED_IN",
            hasCustomRouting: false,
            customRouting: [],
            status: "OPTED_IN",
            topicId: id,
            topicName: id,
            sectionName: "Section \(section)",
            sectionId: section
        )
    }

    private func page(_ topicIds: [String], cursor: String?, more: Bool) throws -> CourierUserPreferences {
        let items = topicIds.map {
            """
            {"default_status":"OPTED_IN","has_custom_routing":false,"custom_routing":[],"status":"OPTED_IN",
             "topic_id":"\($0)","topic_name":"\($0)","section_name":"Section a","section_id":"a"}
            """
        }
        let cursorJSON = cursor.map { "\"\($0)\"" } ?? "null"
        let json = #"{"items":[\#(items.joined(separator: ","))],"paging":{"cursor":\#(cursorJSON),"more":\#(more)}}"#
        return try JSONDecoder().decode(CourierUserPreferences.self, from: Data(json.utf8))
    }

    // MARK: Brand

    func testBrandFailureDoesNotThrow() async {
        let brand = await CourierPreferences.fetchBrand { throw BrandUnavailable() }
        XCTAssertNil(brand)
    }

    // MARK: Paging

    func testFollowsCursorAcrossPages() async throws {
        let pages = [
            nil: try page(["one", "two"], cursor: "page-2", more: true),
            "page-2": try page(["three"], cursor: nil, more: false)
        ]
        var requested = [String?]()

        let topics = try await CourierPreferences.fetchAllTopics { cursor in
            requested.append(cursor)
            return pages[cursor]
        }

        XCTAssertEqual(topics.map(\.topicId), ["one", "two", "three"])
        XCTAssertEqual(requested, [nil, "page-2"])
    }

    func testSinglePageMakesOneRequest() async throws {
        var requests = 0
        let topics = try await CourierPreferences.fetchAllTopics { _ in
            requests += 1
            return try self.page(["one"], cursor: "ignored", more: false)
        }
        XCTAssertEqual(topics.map(\.topicId), ["one"])
        XCTAssertEqual(requests, 1)
    }

    func testRepeatedCursorStops() async throws {
        var requests = 0
        let topics = try await CourierPreferences.fetchAllTopics { _ in
            requests += 1
            return try self.page(["one"], cursor: "same", more: true)
        }
        XCTAssertEqual(requests, 2)
        XCTAssertEqual(topics.count, 2)
    }

    func testPageErrorFailsTheLoad() async {
        do {
            _ = try await CourierPreferences.fetchAllTopics { _ in throw CourierError.userNotFound }
            XCTFail("A failed page should fail the load")
        } catch {}
    }

    // MARK: Sections

    func testSectionsKeepFirstSeenOrder() {
        let sections = CourierPreferences.sections(from: [
            topic("1", section: "b"),
            topic("2", section: "a"),
            topic("3", section: "b")
        ])
        XCTAssertEqual(sections.map(\.id), ["b", "a"])
        XCTAssertEqual(sections.map { $0.topics.map(\.topicId) }, [["1", "3"], ["2"]])
        XCTAssertEqual(sections.first?.title, "Section b")
    }

    // MARK: Decoding

    // The single-topic read leaves out the section fields for a topic that isn't in a section
    func testTopicWithoutASectionDecodes() throws {
        let json = #"{"topic":{"default_status":"OPTED_IN","has_custom_routing":false,"custom_routing":[],"status":"OPTED_OUT","topic_id":"t","topic_name":"Topic"}}"#
        let topic = try JSONDecoder().decode(CourierUserPreferencesTopicResponse.self, from: Data(json.utf8)).topic
        XCTAssertEqual(topic.topicId, "t")
        XCTAssertEqual(topic.status, .optedOut)
        XCTAssertEqual(topic.sectionName, "")
        XCTAssertEqual(topic.sectionId, "")
    }

    func testTopicWithoutRoutingFieldsDecodes() throws {
        let json = #"{"default_status":"OPTED_IN","status":"OPTED_IN","topic_id":"t","topic_name":"Topic","section_name":"S","section_id":"s"}"#
        let topic = try JSONDecoder().decode(CourierUserPreferencesTopic.self, from: Data(json.utf8))
        XCTAssertEqual(topic.customRouting, [])
        XCTAssertFalse(topic.hasCustomRouting)
        XCTAssertEqual(topic.sectionName, "S")
    }

    func testTopicWithoutAnIdFailsToDecode() {
        let json = #"{"default_status":"OPTED_IN","status":"OPTED_IN","topic_name":"Topic"}"#
        XCTAssertThrowsError(try JSONDecoder().decode(CourierUserPreferencesTopic.self, from: Data(json.utf8)))
    }

}
