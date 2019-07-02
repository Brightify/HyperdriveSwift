//
//  DatePickerMode.swift
//  Hyperdrive
//
//  Created by Matouš Hýbl on 23/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

public enum DatePickerMode: String, EnumPropertyType, AttributeSupportedPropertyType {
    public static let enumName = "UIDatePickerMode"
    public static let typeFactory = TypeFactory()

    case date
    case time
    case dateAndTime
    case countDownTimer

    public final class TypeFactory: EnumTypeFactory {
        public typealias BuildType = DatePickerMode

        public init() { }
    }
}

#if canImport(UIKit)
import UIKit

extension DatePickerMode {
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        #if os(tvOS)
            return nil
        #else
        switch self {
        case .time:
            return UIDatePicker.Mode.time.rawValue
        case .date:
            return UIDatePicker.Mode.date.rawValue
        case .dateAndTime:
            return UIDatePicker.Mode.dateAndTime.rawValue
        case .countDownTimer:
            return UIDatePicker.Mode.countDownTimer.rawValue
        }
        #endif
    }
}
#endif
