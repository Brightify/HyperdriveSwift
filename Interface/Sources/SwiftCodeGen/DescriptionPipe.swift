//
//  DescriptionPipe.swift
//  SwiftCodeGen
//
//  Created by Tadeas Kriz on 09/12/2019.
//

public class DescriptionPipe {
    public enum Encapsulation {
        case none
        case parentheses
        case brackets
        case braces
        case custom(open: String, close: String)

        var open: String {
            switch self {
            case .none:
                return ""
            case .parentheses:
                return "("
            case .brackets:
                return "["
            case .braces:
                return "{"
            case .custom(let open, _):
                return open
            }
        }

        var close: String {
            switch self {
            case .none:
                return ""
            case .parentheses:
                return ")"
            case .brackets:
                return "]"
            case .braces:
                return "}"
            case .custom(_, let close):
                return close
            }
        }
    }

    public private(set) var result: [String] = [""]
    private var indentationLevel = 0
    private var lastLine: String {
        get {
            return result[result.endIndex - 1]
        }
        set {
            result[result.endIndex - 1] = newValue
        }
    }

    public init() {

    }

    @discardableResult
    public func block(
        line lineContent: String? = nil,
        encapsulateIn encapsulation: Encapsulation = .braces,
        header: String? = nil,
        descriptionBlock: () throws -> Void
    ) rethrows -> DescriptionPipe {
        lineEnd("\(lineContent.format(into: { "\($0) " }))\(encapsulation.open)\(header.format(into: { " \($0) in" }))")
        defer { line("\(encapsulation.close)") }
        try indented(descriptionBlock: descriptionBlock)

        return self
    }

    @discardableResult
    public func indented(descriptionBlock: () throws -> Void) rethrows -> DescriptionPipe {
        indentationLevel += 1
        defer {
            endOfLineIfNeeded()
            indentationLevel -= 1
        }
        try descriptionBlock()
        return self
    }

    @discardableResult
    public func endOfLineIfNeeded() -> DescriptionPipe {
        if lastLine != "" {
            result.append("")
        }
        return self
    }

    @discardableResult
    public func lineEnd(_ lineEndString: String = "") -> DescriptionPipe {
        string(lineEndString)
        result.append("")
        return self
    }

    @discardableResult
    public func string(_ string: String) -> DescriptionPipe {
        if lastLine == "" {
            lastLine = String(repeating: "\t", count: indentationLevel)
        }

        lastLine += string
        return self
    }

    @discardableResult
    public func line(_ contents: String = "") -> DescriptionPipe {
        if lastLine != "" {
            result.append("")
        }
        string(contents)
        result.append("")
        return self
    }

    @discardableResult
    public func line(times: Int) -> DescriptionPipe {
        let extraLines = lastLine == "" ? 0 : 1
        result.append(contentsOf: Array(repeating: "", count: times + extraLines))
        return self
    }

    @discardableResult
    public func lines(_ lines: String...) -> DescriptionPipe {
        self.lines(lines)
        return self
    }

    @discardableResult
    public func lines(_ lines: [String]) -> DescriptionPipe {
        let linesToAppend: [String]
        if lines.last == "" {
            linesToAppend = lines.dropLast()
        } else {
            linesToAppend = lines
        }
        linesToAppend.forEach { line($0) }
        return self
    }

    @discardableResult
    public func spaced(linePadding: Int = 1, describables: Describable...) -> DescriptionPipe {
        spaced(linePadding: linePadding, describables: describables)
        return self
    }

    @discardableResult
    public func spaced(linePadding: Int = 1, describables: [Describable]) -> DescriptionPipe {
        for (index, describable) in describables.enumerated() {
            describable.describe(into: self)
            if index != describables.endIndex - 1 {
                line(times: linePadding)
            }
        }
        return self
    }

    @discardableResult
    public func spaced(linePadding: Int = 1, describables: [(linePadding: Int, describables: [Describable])]) -> DescriptionPipe {
        return spaced(linePadding: linePadding, blocks: describables.map { padding, describables in
            { self.spaced(linePadding: padding, describables: describables) }
        })
    }

    @discardableResult
    public func spaced(linePadding: Int = 1, blocks: (() -> Void)...) -> DescriptionPipe {
        return spaced(linePadding: linePadding, blocks: blocks)
    }


    @discardableResult
    public func spaced(linePadding: Int = 1, blocks: [() -> Void]) -> DescriptionPipe {
        for (index, block) in blocks.enumerated() {
            let oldCount = self.result.count
            block()
            let newCount = self.result.count
            if oldCount != newCount && index != blocks.endIndex - 1 {
                line(times: linePadding)
            }
        }
        return self
    }

    @discardableResult
    public func append(_ describable: Describable) -> DescriptionPipe {
        describable.describe(into: self)
        return self
    }

    @discardableResult
    public func append<T: Describable>(_ describables: [T]) -> DescriptionPipe {
        describables.forEach {
            append($0)
        }
        return self
    }
}

extension DescriptionPipe: Describable {
    public func describe(into pipe: DescriptionPipe) {
        pipe.lines(result)
    }
}
