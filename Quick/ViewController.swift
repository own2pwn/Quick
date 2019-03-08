//
//  ViewController.swift
//  Quick
//
//  Created by Evgeniy on 08/03/2019.
//  Copyright © 2019 Surge. All rights reserved.
//

import UIKit

typealias JSON = [String: Any]

enum QuickViewType {
    case plain
}

protocol QuickViewSpec {
    var name: String { get }
    var quickType: QuickViewType { get }

    var backgroundColor: UIColor? { get }
}

struct QuickViewSpecImp: QuickViewSpec {
    let name: String
    let quickType: QuickViewType

    let backgroundColor: UIColor?
}

open class QuickView: UIView {
    // MARK: - Members

    open var identifier: String

    // public let spec: QuickViewSpec

    // MARK: - Init

    init(spec: QuickViewSpec) {
        identifier = spec.name
        super.init(frame: .zero)

        backgroundColor = spec.backgroundColor
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError() }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        testJSON()
    }

    private func testJSON() {
        let str: String = "{\"name\":\"card\",\"backgroundColor\":\"#343F4B\",\"type\":0,\"layout\":[{\"method\":3,\"arguments\":[\"16\"]},{\"method\":2,\"arguments\":[\"128\"]},{\"method\":6,\"arguments\":[\"8\"]}]}"
        if let d = str.data(using: .utf8) {
            let qv = QuickViewSpecImp(data: d)
        }
    }
}

// ======

let PlainView: Int = 0

extension QuickViewType {
    init?(rawValue: Int) {
        switch rawValue {
        case PlainView:
            self = .plain
        default:
            return nil
        }
    }
}

// ======

extension QuickViewSpecImp {
    init?(data: Data) {
        guard
            let object = try? JSONSerialization.jsonObject(
                with: data, options: []
            ), let json = object as? JSON
        else { return nil }

        guard
            let name = json["name"] as? String,
            let viewType = json["type"] as? Int,
            let quickType = QuickViewType(rawValue: viewType)
        else { return nil }

        self.name = name
        self.quickType = quickType
        let colorValue: String? = json["backgroundColor"] as? String

        backgroundColor = UIColor.hex(colorValue)
    }
}
