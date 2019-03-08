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
    var backgroundColor: UIColor? { get }
}

struct QuickViewSpecImp: QuickViewSpec {
    let backgroundColor: UIColor?
}

protocol QuickSpec {
    var name: String { get }
    var quickType: QuickViewType { get }

    var viewSpec: QuickViewSpec { get }
}

struct QuickSpecImp: QuickSpec {
    let name: String
    let quickType: QuickViewType

    let viewSpec: QuickViewSpec
}

open class QuickView: UIView {
    // MARK: - Members

    open var identifier: String

    // public let spec: QuickViewSpec

    // MARK: - Init

    init(spec: QuickSpec) {
        identifier = spec.name
        super.init(frame: .zero)

        backgroundColor = spec.viewSpec.backgroundColor
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError() }
}

final class Bootstrapper {

// MARK: - Members

    private typealias Setup = (UIView, QuickSpec) -> Void

    // MARK: - Interface

    func bootstrap(_ view: UIView, spec: QuickSpec) {
        guard let setup = quickTypeToSetup[spec.quickType] else {
            return
        }
        setup(view, spec)
    }

    // MARK: - Helpers

    private func bootstrapPlain(_ view: UIView, spec: QuickSpec) {
        
    }

    // MARK: - Strategy

    private lazy var quickTypeToSetup: [QuickViewType: Setup] = {
        let strategy = [
            QuickViewType.plain: bootstrapPlain,
        ]

        return strategy
    }()
}

final class Producer {
    // MARK: - Members

    private typealias Builder = (QuickSpec) -> UIView

    private lazy var bootstrap:
        Bootstrapper = Bootstrapper()

    // MARK: - Interface

    func makeView(spec: QuickSpec) -> UIView {
        guard let maker = quickTypeToBuilder[spec.quickType] else {
            assertionFailure()
            return UIView()
        }

        return maker(spec)
    }

    // MARK: - Helpers

    private func makePlainView(spec: QuickSpec) -> UIView {
        let plain = UIView()
        bootstrap.bootstrap(plain, spec: spec)


        return plain
    }

    private lazy var quickTypeToBuilder: [QuickViewType: Builder] = {
        let factory = [
            QuickViewType.plain: makePlainView,
        ]

        return factory
    }()
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        testJSON()
    }

    private func testJSON() {
        let str: String = "{\"name\":\"card\",\"backgroundColor\":\"#343F4B\",\"type\":0,\"layout\":[{\"method\":3,\"arguments\":[\"16\"]},{\"method\":2,\"arguments\":[\"128\"]},{\"method\":6,\"arguments\":[\"8\"]}]}"
        if let d = str.data(using: .utf8) {
            let qv = QuickSpecImp(data: d)
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

extension QuickSpecImp {
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

        let viewSpec = QuickViewSpecImp(
            backgroundColor: UIColor.hex(colorValue)
        )
        self.viewSpec = viewSpec
    }
}
