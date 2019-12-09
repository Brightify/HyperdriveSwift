import Foundation
import Tokenizer
import SwiftCodeGen

public class Generator {
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
                // FIXME Let's think about the space here, do we want to remove it?
                return " {"
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

    let configuration: GeneratorConfiguration

    var nestLevel: Int = 0

    init(configuration: GeneratorConfiguration) {
        self.configuration = configuration
    }
    
    var output = ""

    func generate(imports: Bool) throws -> Describable {
        return ""
    }
    
    func ifSimulator(_ commands: String) -> [String] {
        if configuration.swiftVersion >= .swift4_1 {
            return [
                "#if targetEnvironment(simulator)",
                "    \(commands)",
                "#endif",
            ]
        } else {
            return [
                "#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))",
                "    \(commands)",
                "#endif",
            ]
        }
    }
}
