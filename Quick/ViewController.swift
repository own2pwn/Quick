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

struct QuickView {
    let name: String
    let type: QuickViewType

    let backgroundColor: UIColor?
}

final class Bootstrapper {
    // MARK: - Interface

    func bootstrap<T:UIView>(nativeType: T.Type, config: QuickView) {

    }
}

final class Producer {
    // MARK: - Interface

    func makeView(config: QuickView) {
        let viewType: UIView.Type = desiredType(for: config.type)
    }

    // MARK: - Helpers

    private func desiredType<T: UIView>(for quickType: QuickViewType) -> T.Type {
        switch quickType {
        case .plain:
            return UIView.self as! T.Type
        }
    }
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        testJSON()
    }

    private func testJSON() {
        let str: String = "{\"name\":\"card\",\"backgroundColor\":\"#343F4B\",\"type\":0,\"layout\":[{\"method\":3,\"arguments\":[\"16\"]},{\"method\":2,\"arguments\":[\"128\"]},{\"method\":6,\"arguments\":[\"8\"]}]}"
        if let d = str.data(using: .utf8) {
            let qv = QuickView(data: d)
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

extension QuickView {
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
        type = quickType
        let colorValue: String? = json["backgroundColor"] as? String

        backgroundColor = UIColor.hex(colorValue)
    }
}
