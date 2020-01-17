//
//  MainDeserializationContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 03/06/2019.
//

public class MainDeserializationContext: DeserializationContext {
    public private(set) var elementFactories: [String: UIElementFactory]
    public let referenceFactoryProvider: ModuleRegistry.ReferenceFactoryProvider
    public let platform: RuntimePlatform

    public init(elementFactories: [UIElementFactory], referenceFactoryProvider: @escaping ModuleRegistry.ReferenceFactoryProvider, platform: RuntimePlatform) {
        self.elementFactories = Dictionary(uniqueKeysWithValues: elementFactories.map { ($0.elementName, $0) })
        self.referenceFactoryProvider = referenceFactoryProvider
        self.platform = platform
    }
}

extension MainDeserializationContext: HasUIElementFactoryRegistry {
    private static let ignoredElements: Set<String> = ["styles", "templates", "overrides", "state", "navigationItem", "rx:disposeBags"]
    private static let ignoredElementPrefixes: Set<String> = ["state:"]

    public func shouldIgnore(elementName: String) -> Bool {
        return Self.ignoredElements.contains(elementName) ||
            Self.ignoredElementPrefixes.contains(where: elementName.hasPrefix)
    }

    public func factory(for elementName: String) -> UIElementFactory? {
        // FIXME We have to move this outside of this method, probably inside ComponentReference so it decides which elements to filter out.
        if shouldIgnore(elementName: elementName) {
            return nil
        } else if let elementFactory = elementFactories[elementName] {
            return elementFactory
        } else {
            let referenceFactory = referenceFactoryProvider(elementName)
            elementFactories[elementName] = referenceFactory
            return referenceFactory
        }
    }
}

extension MainDeserializationContext: CanDeserializeDefinition {
    public func deserialize(element: XMLElement, type: String) throws -> ComponentDefinition {
        let context = ComponentDeserializationContext(parentContext: self, element: element, type: type, elementIdProvider: ElementIdProvider(prefix: ""))
        return try ComponentDefinition(context: context)
    }
}

extension MainDeserializationContext: CanDeserializeStyleGroup {
    public func deserialize(element: XMLElement) throws -> StyleGroup {
        let context = StyleGroupDeserializationContext(parentContext: self, element: element)
        return try StyleGroup(context: context)
    }
}
