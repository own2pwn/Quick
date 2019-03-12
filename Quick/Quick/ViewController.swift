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

let LayoutMethodAfter: Int = 10
let LayoutMethodBefore: Int = 11

let LayoutMethodSizeToFit: Int = 12
let LayoutMethodSizeToFitWidth: Int = 13
let LayoutMethodSizeToFitHeight: Int = 14

public enum QuickLayoutMethodArgument {
    case constant(CGFloat)
    case containerSafeArea

    case verticalAlign(UIView, CGFloat, VerticalAlign)
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

    case after
    case before

    case sizeToFit
    case sizeToFitWidth
    case sizeToFitHeight
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

        case LayoutMethodAfter:
            self = .after
        case LayoutMethodBefore:
            self = .before

        case LayoutMethodSizeToFit:
            self = .sizeToFit
        case LayoutMethodSizeToFitWidth:
            self = .sizeToFitWidth
        case LayoutMethodSizeToFitHeight:
            self = .sizeToFitHeight

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
    case label
}

public protocol QuickViewSpec {
    var baseSpec: QuickViewBaseSpec { get }
}

struct QuickViewSpecImp: QuickViewSpec {
    let baseSpec: QuickViewBaseSpec
}

public protocol QuickViewBaseSpec {
    var backgroundColor: UIColor? { get }

    var cornerRadius: CGFloat? { get }
}

struct QuickViewBaseSpecImp: QuickViewBaseSpec {
    let backgroundColor: UIColor?

    let cornerRadius: CGFloat?
}

protocol QuickLabelSpec: QuickViewSpec {
    var text: String? { get }
    var textColor: UIColor? { get }
    var font: UIFont? { get }
}

struct QuickLabelSpecImp: QuickLabelSpec {
    let baseSpec: QuickViewBaseSpec

    let text: String?
    let textColor: UIColor?
    let font: UIFont?
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

        case .after:
            pin.after(of: <#T##UIView#>, aligned: <#T##VerticalAlign#>)
        case .before:
            <#code#>
        case .sizeToFit:
            <#code#>
        case .sizeToFitWidth:
            <#code#>
        case .sizeToFitHeight:
            <#code#>
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

extension UIView {
    func setup(with spec: QuickViewSpec) {
        backgroundColor = spec.baseSpec.backgroundColor
        if let corner = spec.baseSpec.cornerRadius {
            layer.cornerRadius = corner
        }
    }
}

protocol IQuickView: class {
    var identifier: String { get set }

    var spec: QuickSpec { get }
}

typealias TQuickView = (IQuickView & UIView)

open class QuickLabel: UILabel, IQuickView {
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

        setupView(with: spec.viewSpec)
        setupSubviews()
    }

    private func setupView(with spec: QuickViewSpec) {
        setup(with: spec)
        guard let labelSpec = spec as? QuickLabelSpec else { return }

        text = labelSpec.text
        textColor = labelSpec.textColor
        font = labelSpec.font
    }

    private func setupSubviews() {
        let producer = Producer()
        let views = spec.subviews.map(producer.makeView)
        views.forEach(addSubview)
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) { fatalError() }

    // MARK: - Layout

    open override func layoutSubviews() {
        super.layoutSubviews()

        Pinner.layout(self, specs: spec.layoutSpecs, in: container)
        subviews.forEach { $0.setNeedsLayout() }
    }
}

open class QuickView: UIView, IQuickView {
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

        setup(with: spec.viewSpec)
        setupSubviews()
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

    private func makeViews(specs: [QuickSpec]) -> [TQuickView] {
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

    private typealias Builder = (QuickSpec, UIView?) -> TQuickView

    private lazy var bootstrap:
        Bootstrapper = Bootstrapper()

    // MARK: - Interface

    func makeView(spec: QuickSpec) -> TQuickView {
        return makeView(spec: spec, in: nil)
    }

    func makeView(spec: QuickSpec, in container: UIView?) -> TQuickView {
        guard let maker = quickTypeToBuilder[spec.quickType] else {
            assertionFailure()
            return QuickView(spec: spec, container: container)
        }

        return maker(spec, container)
    }

    // MARK: - Helpers

    private func makePlainView(spec: QuickSpec, container: UIView?) -> TQuickView {
        let plain = QuickView(spec: spec, container: container)

        return plain
    }

    private func makeLabel(spec: QuickSpec, container: UIView?) -> TQuickView {
        let label = QuickLabel(spec: spec, container: container)

        return label
    }

    private lazy var quickTypeToBuilder: [QuickViewType: Builder] = {
        let factory = [
            QuickViewType.plain: makePlainView,
            QuickViewType.label: makeLabel,
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
        if let d = viewJSON.data(using: .utf8), let qc = QuickControllerSpecImp(data: d) {
            setup(with: qc)
        }
    }
}

// ======

let PlainView: Int = 0
let LabelView: Int = 1

extension QuickViewType {
    init?(rawValue: Int) {
        guard
            let value = QuickViewType.IntToType[rawValue]
        else { return nil }

        self = value
    }

    // MARK: - Strategy

    private static let IntToType: [Int: QuickViewType] = {
        let strategy: [Int: QuickViewType] = [
            PlainView: .plain,
            LabelView: .label,
        ]

        return strategy
    }()
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
        viewSpec = QuickSpecImp.parseViewSpecs(
            json: json,
            viewType: quickType
        )
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
        viewSpec = QuickSpecImp.parseViewSpecs(
            json: json,
            viewType: quickType
        )
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

    private static func parseViewSpecs(json: JSON, viewType: QuickViewType) -> QuickViewSpec {
        let baseSpec: QuickViewBaseSpec = parseBaseViewSpecs(json: json)

        switch viewType {
        case .plain:
            return parsePlainViewSpecs(base: baseSpec)
        case .label:
            return parseLabelViewSpecs(
                base: baseSpec, json: json
            )
        }
    }

    private static func parseBaseViewSpecs(json: JSON) -> QuickViewBaseSpec {
        let colorValue: String? = json["backgroundColor"] as? String
        var cornerRadius: CGFloat?

        if let radiusProperty = json["corner"] as? String,
            let radiusValue = Double(radiusProperty) {
            cornerRadius = CGFloat(radiusValue)
        }

        return QuickViewBaseSpecImp(
            backgroundColor: UIColor.hex(colorValue),
            cornerRadius: cornerRadius
        )
    }

    private static func parsePlainViewSpecs(base: QuickViewBaseSpec) -> QuickViewSpec {
        return QuickViewSpecImp(
            baseSpec: base
        )
    }

    private static func parseLabelViewSpecs(base: QuickViewBaseSpec, json: JSON) -> QuickViewSpec {
        let text = json["text"] as? String
        let colorValue: String? = json["textColor"] as? String
        let textColor = UIColor.hex(colorValue)

        var fontSize: CGFloat?
        let fontDict: JSON? = json["font"] as? JSON
        let fontName: String? = fontDict?["name"] as? String
        let fontWeight: Int? = fontDict?["weight"] as? Int

        if let fontSizeProperty = fontDict?["size"] as? String, let fontSizeValue = Double(fontSizeProperty) {
            fontSize = CGFloat(fontSizeValue)
        }

        return QuickLabelSpecImp(
            baseSpec: base,
            text: text,
            textColor: textColor,
            font: UIFont.named(
                fontName,
                size: fontSize,
                weight: fontWeight
            )
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

extension UIFont {
    static func named(_ name: String?, size: CGFloat?, weight: Int?) -> UIFont? {
        guard let name = name, let size = size, let weight = weight else {
            return nil
        }
        let fontWeight = UIFont.Weight(CGFloat(weight))

        return named(name, size: size, weight: fontWeight)
    }

    private static func named(_ name: String, size: CGFloat, weight: UIFont.Weight) -> UIFont? {
        switch name {
        case "system":
            return UIFont.systemFont(ofSize: size, weight: weight)
        default:
            return nil
        }
    }
}

let viewJSON: String = "{\"name\":\"CardController\",\"type\":0,\"container\":{\"name\":\"container\",\"type\":0,\"subviews\":[{\"name\":\"notification\",\"corner\":\"8\",\"backgroundColor\":\"#343F4B\",\"type\":0,\"subviews\":[{\"name\":\"badge\",\"corner\":\"5\",\"backgroundColor\":\"#C0CCDA\",\"type\":0,\"layout\":[{\"method\":3,\"arguments\":[\"8\"]},{\"method\":7,\"arguments\":[\"8\"]},{\"method\":0,\"arguments\":[\"20\"]}]},{\"name\":\"messageLabel\",\"type\":1,\"layout\":[{\"method\":10,\"arguments\":[\"badge\",\"8\",0]},{\"method\":6,\"arguments\":[\"16\"]},{\"method\":13}],\"text\":\"MESSAGES\",\"textColor\":\"#8392A7\",\"font\":{\"name\":\"system\",\"size\":\"14\",\"weight\":0}}],\"layout\":[{\"method\":3,\"arguments\":[\"container.safeArea\"]},{\"method\":9,\"arguments\":[\"16\"]},{\"method\":2,\"arguments\":[\"128\"]},{\"method\":8,\"arguments\":[\"8\"]}]}]}}"
