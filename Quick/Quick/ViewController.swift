//
//  ViewController.swift
//  Quick
//
//  Created by Evgeniy on 08/03/2019.
//  Copyright © 2019 Surge. All rights reserved.
//

import PinLayout
import UIKit

typealias JSON = [String: Any]

let LayoutMethodSize: Int = 0
let LayoutMethodWidth: Int = 1
let LayoutMethodHeight: Int = 2

let LayoutMethodTop: Int = 3
let LayoutMethodBottom: Int = 4
let LayoutMethodVertically: Int = 5

let LayoutMethodEnd: Int = 6
let LayoutMethodStart: Int = 7
let LayoutMethodHorizontally: Int = 8

public enum QuickLayoutMethod {
    case size(CGFloat)
    case width(CGFloat)
    case height(CGFloat)

    case top(CGFloat)
    case bottom(CGFloat)
    case vertically(CGFloat)

    case end(CGFloat)
    case start(CGFloat)
    case horizontally(CGFloat)
}

extension QuickLayoutMethod: Hashable {}

extension QuickLayoutMethod {
    init?(rawValue: Int, arg: CGFloat) {
        switch rawValue {
        case LayoutMethodSize:
            self = .size(arg)
        case LayoutMethodWidth:
            self = .width(arg)
        case LayoutMethodHeight:
            self = .height(arg)

        case LayoutMethodTop:
            self = .top(arg)
        case LayoutMethodBottom:
            self = .bottom(arg)
        case LayoutMethodVertically:
            self = .vertically(arg)

        case LayoutMethodEnd:
            self = .end(arg)
        case LayoutMethodStart:
            self = .start(arg)
        case LayoutMethodHorizontally:
            self = .horizontally(arg)

        default:
            return nil
        }
    }
}

public protocol QuickLayoutSpec {
    var method: QuickLayoutMethod { get }
}

struct QuickLayoutSpecImp: QuickLayoutSpec {
    let method: QuickLayoutMethod
}

public enum QuickViewType {
    case plain
}

public protocol QuickViewSpec {
    var backgroundColor: UIColor? { get }
}

struct QuickViewSpecImp: QuickViewSpec {
    let backgroundColor: UIColor?
}

public protocol QuickSpec {
    var name: String { get }
    var quickType: QuickViewType { get }

    var viewSpec: QuickViewSpec { get }
    var layoutSpecs: [QuickLayoutSpec] { get }
}

struct QuickSpecImp: QuickSpec {
    let name: String
    let quickType: QuickViewType

    let viewSpec: QuickViewSpec
    let layoutSpecs: [QuickLayoutSpec]
}

final class Pinner {
    // MARK: - Members

    typealias Action = (CGFloat) -> PinLayout<UIView>

    typealias Pin = PinLayout<UIView>

    // MARK: - Interface

    static func layout(_ view: UIView, specs: [QuickLayoutSpec]) {
        let viewPin = view.pin

        for spec in specs {
            apply(spec: spec, to: viewPin)
            // let pinAction = action(pin: viewPin, for: spec)
        }
    }

    // MARK: - Helpers

    private static func apply(spec: QuickLayoutSpec, to pin: Pin) {
        switch spec.method {
        case let .size(s):
            pin.size(s)
        case let .width(w):
            pin.width(w)
        case let .height(h):
            pin.height(h)

        case let .top(m):
            pin.top(m)
        case let .bottom(m):
            pin.bottom(m)
        case let .vertically(m):
            pin.vertically(m)

        case let .end(m):
            pin.end(m)
        case let .start(m):
            pin.start(m)
        case let .horizontally(m):
            pin.horizontally(m)
        }
    }

    private static func action(pin: PinLayout<UIView>, for spec: QuickLayoutSpec) -> Action {
        switch spec.method {
        case .top:
            return pin.top
        case .bottom:
            return pin.bottom
        case .vertically:
            return pin.vertically

        case .size:
            return pin.size
        case .width:
            return pin.width
        case .height:
            return pin.height

        case .end:
            return pin.end
        case .start:
            return pin.start
        case .horizontally:
            return pin.horizontally
        }
    }
}

open class QuickView: UIView {
    // MARK: - Members

    open var identifier: String

    public let spec: QuickSpec

    // MARK: - Init

    public init(spec: QuickSpec) {
        identifier = spec.name
        self.spec = spec
        super.init(frame: .zero)

        backgroundColor = spec.viewSpec.backgroundColor
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError() }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()

        Pinner.layout(self, specs: spec.layoutSpecs)
    }
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

    private func bootstrapPlain(_: UIView, spec _: QuickSpec) {}

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
        let plain = QuickView(spec: spec)

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
        let str: String = "{\"name\":\"card\",\"backgroundColor\":\"#343F4B\",\"type\":0,\"layout\":[{\"method\":3,\"arguments\":[\"16\"]},{\"method\":2,\"arguments\":[\"128\"]},{\"method\":8,\"arguments\":[\"8\"]}]}"
        if let d = str.data(using: .utf8), let qv = QuickSpecImp(data: d) {
            let v = Producer().makeView(spec: qv)
            view.addSubview(v)
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
        layoutSpecs = QuickSpecImp.parseLayout(json: json)
    }

    // MARK: - Helpers

    private static func parseLayout(json: JSON) -> [QuickLayoutSpec] {
        guard let layout = json["layout"] as? [JSON] else {
            return []
        }
        var result: [QuickLayoutSpec] = []

        for spec in layout {
            let arg = getArgumentValue(spec: spec)
            if let methodValue = spec["method"] as? Int,
                let method = QuickLayoutMethod(rawValue: methodValue, arg: arg) {
                let newSpec = QuickLayoutSpecImp(method: method)
                result.append(newSpec)
            }
        }

        return result
    }

    private static func getArgumentValue(spec: JSON) -> CGFloat {
        guard let values = spec["arguments"] as? [Any], !values.isEmpty else {
            return 0
        }
        guard let argValue = values[0] as? String else {
            return 0
        }
        if let floatValue = Double(argValue) {
            return CGFloat(floatValue)
        }
        if let intValue = Int(argValue) {
            return CGFloat(intValue)
        }

        return 0
    }
}
