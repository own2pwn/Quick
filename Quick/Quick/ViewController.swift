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
let LayoutMethodMarginBottom: Int = 10

let LayoutMethodAbove: Int = 11
let LayoutMethodBelow: Int = 12

let LayoutMethodAfter: Int = 13
let LayoutMethodBefore: Int = 14

let LayoutMethodSizeToFit: Int = 15
let LayoutMethodSizeToFitWidth: Int = 16
let LayoutMethodSizeToFitHeight: Int = 17

let LayoutMethodVertCenterTo: Int = 18
let LayoutMethodHoriCenterTo: Int = 19

let LayoutMethodVertCenter: Int = 20
let LayoutMethodHoriCenter: Int = 21

let LayoutMethodAll: Int = 22
let LayoutMethodCenter: Int = 23
let LayoutMethodUpdate: Int = 24

public enum QuickLayoutMethodArgument {
    case constant(CGFloat)
    case containerSafeArea

    case vCenterTo(String, CGFloat)
    case hCenterTo(String, CGFloat)

    case verticalAlign(String, CGFloat, VerticalAlign)
    case horizontalAlign(String, CGFloat, HorizontalAlign)
}

public extension QuickLayoutMethodArgument {
    var argValue: CGFloat? {
        switch self {
        case let .constant(value):
            return value

        default:
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

    case above
    case below

    case after
    case before

    case sizeToFit
    case sizeToFitWidth
    case sizeToFitHeight

    case vCenter
    case vCenterTo

    case hCenter
    case hCenterTo

    case all
    case center
    case update
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

        case LayoutMethodAbove:
            self = .above

        case LayoutMethodBelow:
            self = .below

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

        case LayoutMethodVertCenter:
            self = .vCenter
        case LayoutMethodVertCenterTo:
            self = .vCenterTo

        case LayoutMethodHoriCenter:
            self = .hCenter
        case LayoutMethodHoriCenterTo:
            self = .hCenterTo

        case LayoutMethodAll:
            self = .all
        case LayoutMethodCenter:
            self = .center
        case LayoutMethodUpdate:
            self = .update

        default:
            return nil
        }
    }
}

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
    var backgroundColor: UIColor { get }

    var cornerRadius: CGFloat? { get }
}

struct QuickViewBaseSpecImp: QuickViewBaseSpec {
    let backgroundColor: UIColor

    let cornerRadius: CGFloat?
}

protocol QuickLabelSpec: QuickViewSpec {
    var text: String? { get }
    var textColor: UIColor? { get }

    var font: UIFont? { get }
    var textAlignment: NSTextAlignment { get }
}

struct QuickLabelSpecImp: QuickLabelSpec {
    let baseSpec: QuickViewBaseSpec

    let text: String?
    let textColor: UIColor?

    let font: UIFont?
    let textAlignment: NSTextAlignment
}

public protocol QuickSpec {
    var name: String { get }
    var quickType: QuickViewType { get }

    var subviews: [QuickSpec] { get }
    var viewSpec: QuickViewSpec { get }
    var layoutSpecs: [QuickLayoutSpec] { get }
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
        var currentPin: Pin = view.pin
        for spec in specs {
            currentPin = apply(spec: spec, to: view, with: currentPin, in: container)
        }
    }

    // MARK: - Helpers

    private static func apply(spec: QuickLayoutSpec, to view: UIView, with pin: Pin, in container: UIView?) -> Pin {
        let viewContainer: UIView = container ?? UIView()
        let const: CGFloat = spec.argument.argValue ?? 0
        var insets: PEdgeInsets = PEdgeInsets(
            top: const, left: const,
            bottom: const, right: const
        )
        if case .containerSafeArea = spec.argument {
            insets = viewContainer.pin.safeArea
        }

        var newPin: Pin = pin
        switch spec.method {
        case .size:
            newPin = pin.size(const)
        case .width:
            newPin = pin.width(const)
        case .height:
            newPin = pin.height(const)

        case .top:
            newPin = pin.top(insets)
        case .bottom:
            newPin = pin.bottom(insets)
        case .vertically:
            newPin = pin.vertically(insets)

        case .end:
            newPin = pin.end(insets)
        case .start:
            newPin = pin.start(insets)
        case .horizontally:
            newPin = pin.horizontally(insets)

        case .marginTop:
            newPin = pin.marginTop(const)

        case .above:
            newPin = pinAbove(spec: spec, pin: pin, view: view)
        case .below:
            newPin = pinBelow(spec: spec, pin: pin, view: view)

        case .after:
            newPin = pinAfter(spec: spec, pin: pin, view: view)
        case .before:
            newPin = pinBefore(spec: spec, pin: pin, view: view)
        case .sizeToFit:
            newPin = pin.sizeToFit()
        case .sizeToFitWidth:
            newPin = pin.sizeToFit(.width)
        case .sizeToFitHeight:
            newPin = pin.sizeToFit(.height)

        case .vCenter:
            newPin = pinVertCenter(pin: pin, margin: const)
        case .vCenterTo:
            newPin = pinVertCenterTo(spec: spec, pin: pin, view: view)

        case .hCenter:
            newPin = pinHoriCenter(pin: pin, margin: const)
        case .hCenterTo:
            newPin = pinHoriCenterTo(spec: spec, pin: pin, view: view)

        case .all:
            newPin = pin.all(const)
        case .center:
            newPin = pin.center(const)
        case .update:
            pin.layout()
            newPin = view.pin
        }

        return newPin
    }

    private static func pinAbove(spec: QuickLayoutSpec, pin: Pin, view: UIView) -> Pin {
        guard
            case let QuickLayoutMethodArgument.horizontalAlign(id, margin, align) = spec.argument,
            let related = view.get(by: id)
        else { return pin }

        let newPin = pin.above(of: related, aligned: align)
            .marginBottom(margin)

        return newPin
    }

    private static func pinBelow(spec: QuickLayoutSpec, pin: Pin, view: UIView) -> Pin {
        guard
            case let QuickLayoutMethodArgument.horizontalAlign(id, margin, align) = spec.argument,
            let related = view.get(by: id)
        else { return pin }

        let newPin = pin.below(of: related, aligned: align)
            .marginTop(margin)

        return newPin
    }

    private static func pinVertCenter(pin: Pin, margin: CGFloat) -> Pin {
        let newPin = pin.vCenter(margin)

        return newPin
    }

    private static func pinVertCenterTo(spec: QuickLayoutSpec, pin: Pin, view: UIView) -> Pin {
        guard
            case let QuickLayoutMethodArgument.vCenterTo(id, margin) = spec.argument,
            let related = view.get(by: id)
        else { return pin }

        let newPin = pin.vCenter(to: related.edge.vCenter)
            .marginVertical(margin)

        return newPin
    }

    private static func pinHoriCenter(pin: Pin, margin: CGFloat) -> Pin {
        let newPin = pin.hCenter(margin)

        return newPin
    }

    private static func pinHoriCenterTo(spec: QuickLayoutSpec, pin: Pin, view: UIView) -> Pin {
        guard
            case let QuickLayoutMethodArgument.hCenterTo(id, margin) = spec.argument,
            let related = view.get(by: id)
        else { return pin }

        let newPin = pin.hCenter(to: related.edge.hCenter)
            .marginHorizontal(margin)

        return newPin
    }

    private static func pinAfter(spec: QuickLayoutSpec, pin: Pin, view: UIView) -> Pin {
        guard
            case let QuickLayoutMethodArgument.verticalAlign(id, margin, align) = spec.argument,
            let related = view.get(by: id)
        else { return pin }

        let newPin = pin.after(of: related, aligned: align)
            .marginStart(margin)

        return newPin
    }

    private static func pinBefore(spec: QuickLayoutSpec, pin: Pin, view: UIView) -> Pin {
        guard
            case let QuickLayoutMethodArgument.verticalAlign(id, margin, align) = spec.argument,
            let related = view.get(by: id)
        else { return pin }

        let newPin = pin.before(of: related, aligned: align)
            .marginEnd(margin)

        return newPin
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

// TODO: container to closure that gets container by request

extension UIView {
    func get(by identifier: String) -> UIView? {
        var topMostView: UIView = self
        while let parent = topMostView.superview {
            topMostView = parent
        }

        return topMostView.getChild(by: identifier)
    }

    // MARK: - Helpers

    private func getParent(by identifier: String) -> UIView? {
        if let quickParent = superview as? IQuickView, quickParent.identifier == identifier {
            return superview
        }
        return superview?.getParent(by: identifier)
    }

    private func getChild(by identifier: String) -> UIView? {
        for child in subviews {
            if let quickChild = child as? IQuickView, quickChild.identifier == identifier {
                return child
            }
        }
        return subviews.compactMap { $0.getChild(by: identifier) }.first
    }

    // ===

    func getQuick(by identifier: String) -> IQuickView? {
        if let parent = getQuickParent(by: identifier) {
            return parent
        }
        if let child = getQuickChild(by: identifier) {
            return child
        }
        return nil
    }

    // MARK: - Helpers

    private func getQuickParent(by identifier: String) -> IQuickView? {
        if let quickParent = superview as? IQuickView, quickParent.identifier == identifier {
            return quickParent
        }
        return superview?.getQuickParent(by: identifier)
    }

    private func getQuickChild(by identifier: String) -> IQuickView? {
        for child in subviews {
            if let quickChild = child as? IQuickView, quickChild.identifier == identifier {
                return quickChild
            }
        }
        return subviews.compactMap { $0.getQuickChild(by: identifier) }.first
    }
}

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
        textAlignment = labelSpec.textAlignment

        if let value = labelSpec.font {
            font = value
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
            backgroundColor: UIColor.hexOrClear(colorValue),
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

        var alignment: NSTextAlignment = .left
        if let alignmentValue = json["textAlignment"] as? Int {
            let leftAlign: Int = 0
            let centerAlign: Int = 1
            let rightAlign: Int = 2

            switch alignmentValue {
            case leftAlign:
                alignment = .left
            case centerAlign:
                alignment = .center
            case rightAlign:
                alignment = .right
            default:
                break
            }
        }

        return QuickLabelSpecImp(
            baseSpec: base,
            text: text,
            textColor: textColor,
            font: UIFont.named(
                fontName,
                size: fontSize,
                weight: fontWeight
            ),
            textAlignment: alignment
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
                    argument: getArgumentValue(
                        method: method,
                        spec: spec
                    )
                )
                result.append(newSpec)
            }
        }

        return result
    }

    private static func getArgumentValue(method: QuickLayoutMethod, spec: JSON) -> QuickLayoutMethodArgument {
        let nothing: QuickLayoutMethodArgument = .constant(0)

        guard let values = spec["arguments"] as? [Any], !values.isEmpty else {
            return nothing
        }
        guard let argValue = values[0] as? String else {
            return nothing
        }
        let marginSet: Set<QuickLayoutMethod> = [
            .after, .before,
            .above, .below,
            .vCenterTo, .hCenterTo,
        ]
        if marginSet.contains(method) {
            guard
                let margin = values[1] as? String,
                let marginValue = Double(margin)
            else { return nothing }

            let floatMargin: CGFloat = CGFloat(marginValue)

            if method == .vCenterTo {
                return QuickLayoutMethodArgument.vCenterTo(argValue, floatMargin)
            }

            if method == .hCenterTo {
                return QuickLayoutMethodArgument.hCenterTo(argValue, floatMargin)
            }

            let threeArgMethods: Set<QuickLayoutMethod> = [
                .after, .before,
                .above, .below,
            ]

            if threeArgMethods.contains(method) {
                guard
                    let align = values[2] as? Int
                else { return nothing }

                if method == .after || method == .before {
                    let verticalAlign: VerticalAlign = VerticalAlign(rawValue: align) ?? .none

                    return QuickLayoutMethodArgument.verticalAlign(argValue, floatMargin, verticalAlign)
                }
                if method == .above || method == .below {
                    let horizontalAlign: HorizontalAlign = HorizontalAlign(rawValue: align) ?? .none

                    return QuickLayoutMethodArgument.horizontalAlign(argValue, floatMargin, horizontalAlign)
                }
            }
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
        let fontWeight = getFontWeight(rawValue: weight)

        return named(name, size: size, weight: fontWeight)
    }

    // MARK: - Helpers

    private static func getFontWeight(rawValue: Int) -> UIFont.Weight {
        let ultraLight: Int = 0
        let thin: Int = 1
        let light: Int = 2
        let regular: Int = 3
        let medium: Int = 4
        let semibold: Int = 5
        let bold: Int = 6
        let heavy: Int = 7
        let black: Int = 8

        let rawToWeight: [Int: UIFont.Weight] = [
            ultraLight: .ultraLight,
            thin: .thin,
            light: .light,
            regular: .regular,
            medium: .medium,
            semibold: .semibold,
            bold: .bold,
            heavy: .heavy,
            black: .black,
        ]
        let result: UIFont.Weight = rawToWeight[rawValue] ?? .regular

        return result
    }

    private static func named(_ name: String, size: CGFloat, weight: UIFont.Weight) -> UIFont? {
        let systemFont: String = "system"

        switch name {
        case systemFont:
            return UIFont.systemFont(ofSize: size, weight: weight)
        default:
            return nil
        }
    }
}

let viewJSON: String = "{\"name\":\"CardController\",\"type\":0,\"container\":{\"name\":\"container\",\"type\":0,\"subviews\":[{\"name\":\"notification\",\"corner\":\"8\",\"backgroundColor\":\"#343F4B\",\"type\":0,\"subviews\":[{\"name\":\"badge\",\"corner\":\"5\",\"backgroundColor\":\"#C0CCDA\",\"type\":0,\"layout\":[{\"method\":3,\"arguments\":[\"8\"]},{\"method\":7,\"arguments\":[\"8\"]},{\"method\":0,\"arguments\":[\"20\"]}]},{\"name\":\"badgeTextLabel\",\"type\":1,\"layout\":[{\"method\":13,\"arguments\":[\"badge\",\"8\",1]},{\"method\":14,\"arguments\":[\"timeLabel\",\"16\",3]},{\"method\":16}],\"lines\":0,\"text\":\"MESSAGES\",\"textColor\":\"#8392A7\",\"textAlignment\":0,\"font\":{\"name\":\"system\",\"size\":\"14\",\"weight\":3}},{\"name\":\"timeLabel\",\"type\":1,\"layout\":[{\"method\":18,\"arguments\":[\"badge\",\"0\"]},{\"method\":6,\"arguments\":[\"16\"]},{\"method\":15}],\"lines\":0,\"text\":\"now\",\"textColor\":\"#8392A7\",\"textAlignment\":2,\"font\":{\"name\":\"system\",\"size\":\"14\",\"weight\":3}},{\"name\":\"titleLabel\",\"type\":1,\"layout\":[{\"method\":12,\"arguments\":[\"badge\",\"8\",4]},{\"method\":6,\"arguments\":[\"16\"]},{\"method\":16}],\"lines\":0,\"text\":\"Your flowers are ready\",\"textColor\":\"#FCFCFC\",\"textAlignment\":0,\"font\":{\"name\":\"system\",\"size\":\"16\",\"weight\":5}},{\"name\":\"subtitleLabel\",\"type\":1,\"layout\":[{\"method\":12,\"arguments\":[\"titleLabel\",\"8\",4]},{\"method\":6,\"arguments\":[\"16\"]},{\"method\":16}],\"lines\":0,\"text\":\"The order has been accepted\",\"textColor\":\"#E3E3E3\",\"textAlignment\":0,\"font\":{\"name\":\"system\",\"size\":\"16\",\"weight\":4}}],\"layout\":[{\"method\":3,\"arguments\":[\"container.safeArea\"]},{\"method\":9,\"arguments\":[\"16\"]},{\"method\":2,\"arguments\":[\"128\"]},{\"method\":8,\"arguments\":[\"8\"]}]},{\"name\":\"orderContainer\",\"corner\":\"5\",\"backgroundColor\":\"#13C361\",\"type\":0,\"subviews\":[{\"name\":\"orderNowLabel\",\"type\":1,\"layout\":[{\"method\":15},{\"method\":24},{\"method\":23,\"arguments\":[\"0\"]}],\"lines\":0,\"text\":\"Order Now\",\"textColor\":\"#FFFFFF\",\"textAlignment\":0,\"font\":{\"name\":\"system\",\"size\":\"20\",\"weight\":5}}],\"layout\":[{\"method\":4,\"arguments\":[\"container.safeArea\"]},{\"method\":10,\"arguments\":[\"24\"]},{\"method\":2,\"arguments\":[\"60\"]},{\"method\":1,\"arguments\":[\"275\"]},{\"method\":21,\"arguments\":[\"0\"]}]}]}}"
