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

let LayoutContainerSafeArea: String = "container.safeArea"

let LayoutMethodSize: Int = 0
let LayoutMethodWidth: Int = 1
let LayoutMethodHeight: Int = 2

let LayoutMethodTop: Int = 3
let LayoutMethodBottom: Int = 4
let LayoutMethodVertically: Int = 5

let LayoutMethodEnd: Int = 6
let LayoutMethodStart: Int = 7
let LayoutMethodHorizontally: Int = 8

let LayoutMethodMarginTop: Int = 9

public enum QuickLayoutMethodArgument {
    case constant(CGFloat)
    case containerSafeArea
}

public extension QuickLayoutMethodArgument {
    var argValue: CGFloat? {
        switch self {
        case let .constant(value):
            return value

        case .containerSafeArea:
            return nil
        }
    }
}

// public enum QuickLayoutMethod {
//    case size(CGFloat)
//    case width(CGFloat)
//    case height(CGFloat)
//
//    case top(CGFloat)
//    case bottom(CGFloat)
//    case vertically(CGFloat)
//
//    case end(CGFloat)
//    case start(CGFloat)
//    case horizontally(CGFloat)
//
//    case marginTop(CGFloat)
// }

public enum QuickLayoutMethod {
    case size
    case width
    case height

    case top
    case bottom
    case vertically

    case end
    case start
    case horizontally

    case marginTop
}

extension QuickLayoutMethod: Hashable {}

extension QuickLayoutMethod {
    init?(rawValue: Int) {
        switch rawValue {
        case LayoutMethodSize:
            self = .size
        case LayoutMethodWidth:
            self = .width
        case LayoutMethodHeight:
            self = .height

        case LayoutMethodTop:
            self = .top
        case LayoutMethodBottom:
            self = .bottom
        case LayoutMethodVertically:
            self = .vertically

        case LayoutMethodEnd:
            self = .end
        case LayoutMethodStart:
            self = .start
        case LayoutMethodHorizontally:
            self = .horizontally

        case LayoutMethodMarginTop:
            self = .marginTop

        default:
            return nil
        }
    }
}

// extension QuickLayoutMethod {
//    init?(rawValue: Int, arg: CGFloat) {
//        switch rawValue {
//        case LayoutMethodSize:
//            self = .size(arg)
//        case LayoutMethodWidth:
//            self = .width(arg)
//        case LayoutMethodHeight:
//            self = .height(arg)
//
//        case LayoutMethodTop:
//            self = .top(arg)
//        case LayoutMethodBottom:
//            self = .bottom(arg)
//        case LayoutMethodVertically:
//            self = .vertically(arg)
//
//        case LayoutMethodEnd:
//            self = .end(arg)
//        case LayoutMethodStart:
//            self = .start(arg)
//        case LayoutMethodHorizontally:
//            self = .horizontally(arg)
//
//        case LayoutMethodMarginTop:
//            self = .marginTop(arg)
//
//        default:
//            return nil
//        }
//    }
// }

public protocol QuickLayoutSpec {
    var method: QuickLayoutMethod { get }
    var argument: QuickLayoutMethodArgument { get }
}

struct QuickLayoutSpecImp: QuickLayoutSpec {
    let method: QuickLayoutMethod
    let argument: QuickLayoutMethodArgument
}

public enum QuickViewType {
    case plain
}

public protocol QuickViewSpec {
    var backgroundColor: UIColor? { get }

    var cornerRadius: CGFloat? { get }
}

struct QuickViewSpecImp: QuickViewSpec {
    let backgroundColor: UIColor?

    let cornerRadius: CGFloat?
}

public protocol QuickSpec {
    var name: String { get }
    var quickType: QuickViewType { get }

    var subviews: [QuickSpec] { get }
    var viewSpec: QuickViewSpec { get }
    var layoutSpecs: [QuickLayoutSpec] { get }

    // var allSubviews: [QuickSpec] { get }
}

public protocol QuickControllerSpec {
    var name: String { get }

    var container: QuickSpec { get }
}

struct QuickControllerSpecImp: QuickControllerSpec {
    let name: String
    let container: QuickSpec
}

struct QuickSpecImp: QuickSpec {
    let name: String
    let quickType: QuickViewType

    let subviews: [QuickSpec]
    let viewSpec: QuickViewSpec
    let layoutSpecs: [QuickLayoutSpec]
}

final class Pinner {
    // MARK: - Members

    typealias Action = (CGFloat) -> PinLayout<UIView>

    typealias Pin = PinLayout<UIView>

    // MARK: - Interface

    static func layout(_ view: UIView, specs: [QuickLayoutSpec], in container: UIView?) {
        let viewPin = view.pin

        for spec in specs {
            apply(spec: spec, to: viewPin, in: container)
            // let pinAction = action(pin: viewPin, for: spec)
        }
    }

    // MARK: - Helpers

    private static func apply(spec: QuickLayoutSpec, to pin: Pin, in container: UIView?) {
        let viewContainer: UIView = container ?? UIView()
        let const: CGFloat = spec.argument.argValue ?? 0
        var insets: PEdgeInsets = PEdgeInsets(
            top: const, left: const,
            bottom: const, right: const
        )
        if case .containerSafeArea = spec.argument {
            insets = viewContainer.pin.safeArea
        }

        switch spec.method {
        case .size:
            pin.size(const)
        case .width:
            pin.width(const)
        case .height:
            pin.height(const)

        case .top:
            pin.top(insets)
        case .bottom:
            pin.bottom(insets)
        case .vertically:
            pin.vertically(insets)

        case .end:
            pin.end(insets)
        case .start:
            pin.start(insets)
        case .horizontally:
            pin.horizontally(insets)

        case .marginTop:
            pin.marginTop(const)
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

        case .marginTop:
            return pin.marginTop
        }
    }
}

open class QuickView: UIView {
    // MARK: - Members

    open var identifier: String

    public let spec: QuickSpec

    private weak var container: UIView?

    // MARK: - Init

    public convenience init(spec: QuickSpec, container: UIView?) {
        self.init(spec: spec)
        self.container = container
    }

    public init(spec: QuickSpec) {
        identifier = spec.name
        self.spec = spec
        super.init(frame: .zero)

        setupView(spec: spec.viewSpec)
        setupSubviews()
    }

    private func setupView(spec: QuickViewSpec) {
        backgroundColor = spec.backgroundColor
        if let corner = spec.cornerRadius {
            layer.cornerRadius = corner
        }
    }

    private func setupSubviews() {
        let producer = Producer()
        let views = spec.subviews.map(producer.makeView)
        views.forEach(addSubview)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError() }

    // MARK: - Layout

//    func quickLayout(container: UIView) {
//        Pinner.layout(self, specs: spec.layoutSpecs, in: container)
//    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        Pinner.layout(self, specs: spec.layoutSpecs, in: container)
        subviews.forEach { $0.setNeedsLayout() }
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

open class QuickController: UIViewController {
    // MARK: - Interface

    open func setup(with spec: QuickControllerSpec) {
        view.subviews.forEach { $0.removeFromSuperview() }
        let newViews = makeViews(specs: spec.container.subviews)
        newViews.forEach(view.addSubview)

        view.setNeedsLayout()
    }

    // MARK: - Helpers

    private func makeViews(specs: [QuickSpec]) -> [QuickView] {
        let producer = Producer()

        return specs.map { producer.makeView(spec: $0, in: view) }
    }

    // MARK: - Layout

    open override func viewDidLayoutSubviews() {
        let quickViews: [QuickView] = view.subviews
            .compactMap { $0 as? QuickView }

        quickViews.forEach { $0.layoutIfNeeded() }
    }
}

final class Producer {
    // MARK: - Members

    private typealias Builder = (QuickSpec, UIView?) -> QuickView

    private lazy var bootstrap:
        Bootstrapper = Bootstrapper()

    // MARK: - Interface

    func makeView(spec: QuickSpec) -> QuickView {
        return makeView(spec: spec, in: nil)
    }

    func makeView(spec: QuickSpec, in container: UIView?) -> QuickView {
        guard let maker = quickTypeToBuilder[spec.quickType] else {
            assertionFailure()
            return QuickView(spec: spec, container: container)
        }

        return maker(spec, container)
    }

    // MARK: - Helpers

    private func makePlainView(spec: QuickSpec, container: UIView?) -> QuickView {
        let plain = QuickView(spec: spec, container: container)

        return plain
    }

    private lazy var quickTypeToBuilder: [QuickViewType: Builder] = {
        let factory = [
            QuickViewType.plain: makePlainView,
        ]

        return factory
    }()
}

class ViewController: QuickController {
    override func viewDidLoad() {
        super.viewDidLoad()

        testJSON()
    }

    private func testJSON() {
        let str: String = "{\"name\":\"CardController\",\"type\":0,\"container\":{\"name\":\"container\",\"type\":0,\"subviews\":[{\"name\":\"notification\",\"corner\":\"8\",\"backgroundColor\":\"#343F4B\",\"type\":0,\"subviews\":[{\"name\":\"badge\",\"corner\":\"5\",\"backgroundColor\":\"#C0CCDA\",\"type\":0,\"layout\":[{\"method\":3,\"arguments\":[\"8\"]},{\"method\":7,\"arguments\":[\"8\"]},{\"method\":0,\"arguments\":[\"20\"]}]}],\"layout\":[{\"method\":3,\"arguments\":[\"container.safeArea\"]},{\"method\":9,\"arguments\":[\"16\"]},{\"method\":2,\"arguments\":[\"128\"]},{\"method\":8,\"arguments\":[\"8\"]}]}]}}"
        if let d = str.data(using: .utf8), let qc = QuickControllerSpecImp(data: d) {
            setup(with: qc)
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

extension QuickControllerSpecImp {
    init?(data: Data) {
        guard
            let object = try? JSONSerialization.jsonObject(
                with: data, options: []
            ), let json = object as? JSON
        else { return nil }

        guard
            let name = json["name"] as? String,
            let containerData = json["container"] as? JSON,
            let container = QuickSpecImp(json: containerData)
        else { return nil }

        self.name = name
        self.container = container
    }
}

extension QuickSpecImp {
    init?(json: JSON) {
        guard
            let name = json["name"] as? String,
            let viewType = json["type"] as? Int,
            let quickType = QuickViewType(rawValue: viewType)
        else { return nil }

        self.name = name
        self.quickType = quickType

        subviews = QuickSpecImp.parseSubviews(json: json)
        viewSpec = QuickSpecImp.parseViewSpecs(json: json)
        layoutSpecs = QuickSpecImp.parseLayout(json: json)
    }

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

        subviews = QuickSpecImp.parseSubviews(json: json)
        viewSpec = QuickSpecImp.parseViewSpecs(json: json)
        layoutSpecs = QuickSpecImp.parseLayout(json: json)
    }

    // MARK: - Helpers

    private static func parseSubviews(json: JSON) -> [QuickSpec] {
        guard let subviews = json["subviews"] as? [JSON] else {
            return []
        }
        return subviews.compactMap(QuickSpecImp.init(json:))
    }

    // MARK: - Helpers

    private static func parseViewSpecs(json: JSON) -> QuickViewSpec {
        let colorValue: String? = json["backgroundColor"] as? String
        var cornerRadius: CGFloat?

        if let radiusProperty = json["corner"] as? String,
            let radiusValue = Double(radiusProperty) {
            cornerRadius = CGFloat(radiusValue)
        }

        return QuickViewSpecImp(
            backgroundColor: UIColor.hex(colorValue),
            cornerRadius: cornerRadius
        )
    }

    // MARK: - Helpers

    private static func parseLayout(json: JSON) -> [QuickLayoutSpec] {
        guard let layout = json["layout"] as? [JSON] else {
            return []
        }
        var result: [QuickLayoutSpec] = []

        for spec in layout {
            if let methodValue = spec["method"] as? Int,
                let method = QuickLayoutMethod(rawValue: methodValue) {
                let newSpec = QuickLayoutSpecImp(
                    method: method,
                    argument: getArgumentValue(spec: spec)
                )
                result.append(newSpec)
            }
        }

        return result
    }

    private static func getArgumentValue(spec: JSON) -> QuickLayoutMethodArgument {
        let nothing: QuickLayoutMethodArgument = .constant(0)

        guard let values = spec["arguments"] as? [Any], !values.isEmpty else {
            return nothing
        }
        guard let argValue = values[0] as? String else {
            return nothing
        }
        if let floatValue = Double(argValue) {
            return .constant(CGFloat(floatValue))
        }
        if let intValue = Int(argValue) {
            return .constant(CGFloat(intValue))
        }

        if argValue == LayoutContainerSafeArea {
            return .containerSafeArea
        }

        return nothing
    }
}
