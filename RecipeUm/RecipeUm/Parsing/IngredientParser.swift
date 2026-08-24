//
//  IngredientParser.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation

struct IngredientParser {
    private let nonNumericAmountTexts = ["약간", "적당량", "취향껏"]
    private let unitPattern = "(작은술|큰술|티스푼|스푼|kg|ml|g|L|l|컵|개|대|쪽|알|장)"
    private let amountPattern = "(\\d+(?:\\.\\d+)?|\\d+/\\d+|반)"

    func parseLine(_ line: String) -> ParsedIngredient {
        let rawText = line.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !rawText.isEmpty else {
            return ParsedIngredient(
                rawText: rawText,
                name: "",
                parseStatus: .needsReview
            )
        }

        if let parsedNonNumeric = parseNonNumericAmount(from: rawText) {
            return parsedNonNumeric
        }

        if let parsedRange = parseRange(from: rawText) {
            return parsedRange
        }

        if let parsedSingleAmount = parseSingleAmount(from: rawText) {
            return parsedSingleAmount
        }

        return ParsedIngredient(
            rawText: rawText,
            name: rawText,
            parseStatus: .needsReview
        )
    }

    func parseLines(_ text: String) -> [ParsedIngredient] {
        text
            .split(whereSeparator: \.isNewline)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map(parseLine)
    }

    private func parseNonNumericAmount(from rawText: String) -> ParsedIngredient? {
        for amountText in nonNumericAmountTexts {
            guard rawText.hasSuffix(amountText) else {
                continue
            }

            let name = rawText
                .dropLast(amountText.count)
                .trimmingCharacters(in: .whitespacesAndNewlines)

            guard !name.isEmpty else {
                return nil
            }

            return ParsedIngredient(
                rawText: rawText,
                name: name,
                amountText: amountText,
                amountValue: nil,
                amountUpperValue: nil,
                unit: nil,
                parseStatus: .parsed
            )
        }

        return nil
    }

    private func parseRange(from rawText: String) -> ParsedIngredient? {
        let pattern = "^(.+?)\\s*\(amountPattern)\\s*[~-]\\s*\(amountPattern)\\s*\(unitPattern)?$"
        guard let match = firstMatch(pattern: pattern, in: rawText) else {
            return nil
        }

        let name = match[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let lowerText = match[2]
        let upperText = match[3]
        let unit = normalizedUnit(match[safe: 4])

        guard
            !name.isEmpty,
            let lowerValue = numericValue(from: lowerText),
            let upperValue = numericValue(from: upperText)
        else {
            return nil
        }

        return ParsedIngredient(
            rawText: rawText,
            name: name,
            amountText: "\(lowerText)~\(upperText)",
            amountValue: lowerValue,
            amountUpperValue: upperValue,
            unit: unit,
            parseStatus: .parsed
        )
    }

    private func parseSingleAmount(from rawText: String) -> ParsedIngredient? {
        let pattern = "^(.+?)\\s*\(amountPattern)\\s*\(unitPattern)?$"
        guard let match = firstMatch(pattern: pattern, in: rawText) else {
            return nil
        }

        let name = match[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let amountText = match[2]
        let unit = normalizedUnit(match[safe: 3])

        guard !name.isEmpty else {
            return nil
        }

        return ParsedIngredient(
            rawText: rawText,
            name: name,
            amountText: amountText,
            amountValue: numericValue(from: amountText),
            amountUpperValue: nil,
            unit: unit,
            parseStatus: .parsed
        )
    }

    private func numericValue(from amountText: String) -> Double? {
        if amountText == "반" {
            return 0.5
        }

        if amountText.contains("/") {
            let parts = amountText.split(separator: "/")
            guard
                parts.count == 2,
                let numerator = Double(parts[0]),
                let denominator = Double(parts[1]),
                denominator != 0
            else {
                return nil
            }

            return numerator / denominator
        }

        return Double(amountText)
    }

    private func normalizedUnit(_ unit: String?) -> String? {
        guard let unit, !unit.isEmpty else {
            return nil
        }

        if unit == "l" {
            return "L"
        }

        return unit
    }

    private func firstMatch(pattern: String, in text: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range) else {
            return nil
        }

        return (0..<match.numberOfRanges).map { index in
            let matchRange = match.range(at: index)
            guard let range = Range(matchRange, in: text) else {
                return ""
            }
            return String(text[range])
        }
    }
}

private extension Array where Element == String {
    subscript(safe index: Int) -> String? {
        guard indices.contains(index), !self[index].isEmpty else {
            return nil
        }

        return self[index]
    }
}

