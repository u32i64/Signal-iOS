//
//  Copyright (c) 2020 Open Whisper Systems. All rights reserved.
//

import Foundation
import PassKit
import SignalServiceKit

public class DonationUtilities: NSObject {
    static var isApplePayAvailable: Bool {
        PKPaymentAuthorizationController.canMakePayments(usingNetworks: supportedNetworks)
    }

    static let supportedNetworks: [PKPaymentNetwork] = [
        .visa,
        .masterCard,
        .amex,
        .discover,
        .JCB,
        .interac
    ]
    
    public enum Symbol: Equatable {
        case before(String)
        case after(String)
        case currencyCode
    }
    
    public struct Presets {
        struct Preset {
            let symbol: Symbol
            let amounts: [UInt]
        }

        static let presets: [Currency.Code: Preset] = [
            "USD": Preset(symbol: .before("$"), amounts: [3, 5, 10, 20, 50, 100]),
            "AUD": Preset(symbol: .before("A$"), amounts: [5, 10, 15, 25, 65, 125]),
            "BRL": Preset(symbol: .before("R$"), amounts: [15, 25, 50, 100, 250, 525]),
            "GBP": Preset(symbol: .before("£"), amounts: [3, 5, 10, 15, 35, 70]),
            "CAD": Preset(symbol: .before("CA$"), amounts: [5, 10, 15, 25, 60, 125]),
            "CNY": Preset(symbol: .before("CN¥"), amounts: [20, 35, 65, 130, 320, 650]),
            "EUR": Preset(symbol: .before("€"), amounts: [3, 5, 10, 15, 40, 80]),
            "HKD": Preset(symbol: .before("HK$"), amounts: [25, 40, 80, 150, 400, 775]),
            "INR": Preset(symbol: .before("₹"), amounts: [100, 200, 300, 500, 1_000, 5_000]),
            "JPY": Preset(symbol: .before("¥"), amounts: [325, 550, 1_000, 2_200, 5_500, 11_000]),
            "KRW": Preset(symbol: .before("₩"), amounts: [3_500, 5_500, 11_000, 22_500, 55_500, 100_000]),
            "PLN": Preset(symbol: .after("zł"), amounts: [10, 20, 40, 75, 150, 375]),
            "SEK": Preset(symbol: .after("kr"), amounts: [25, 50, 75, 150, 400, 800]),
            "CHF": Preset(symbol: .currencyCode, amounts: [3, 5, 10, 20, 50, 100])
        ]

        static func symbol(for code: Currency.Code) -> Symbol {
            presets[code]?.symbol ?? .currencyCode
        }
    }
    
    static func formatCurrency(_ value: NSDecimalNumber, currencyCode: Currency.Code, includeSymbol: Bool = true) -> String {
        let isZeroDecimalCurrency = Stripe.zeroDecimalCurrencyCodes.contains(currencyCode)

        let decimalPlaces: Int
        if isZeroDecimalCurrency {
            decimalPlaces = 0
        } else if value.doubleValue == Double(value.intValue) {
            decimalPlaces = 0
        } else {
            decimalPlaces = 2
        }
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .decimal
        currencyFormatter.minimumFractionDigits = decimalPlaces
        currencyFormatter.maximumFractionDigits = decimalPlaces

        let valueString = currencyFormatter.string(from: value) ?? value.stringValue

        guard includeSymbol else { return valueString }

        switch Presets.symbol(for: currencyCode) {
        case .before(let symbol): return symbol + valueString
        case .after(let symbol): return valueString + symbol
        case .currencyCode: return currencyCode + " " + valueString
        }
    }
    
    
}
