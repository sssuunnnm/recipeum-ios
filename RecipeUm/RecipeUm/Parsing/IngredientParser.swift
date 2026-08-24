//
//  IngredientParser.swift
//  RecipeUm
//
//  Created by Codex on 8/24/26.
//

import Foundation

struct IngredientParser {
    private let nonNumericAmountTexts = ["약간", "적당량", "취향껏"]
    private let unitPattern = "(작은술|큰술|티스푼|스푼|킬로그램|킬로|키로|밀리리터|밀리|미리|그램|그람|리터|kg|ml|g|L|l|컵|개|대|쪽|알|장)"
    private let amountPattern = "(\\d+(?:\\.\\d+)?|\\d+/\\d+|반)"

    func parseLine(_ line: String) -> ParsedIngredient {
        let rawText = line.trimmingCharacters(in: .whitespacesAndNewlines)
        let parseText = normalizedParseText(from: rawText)

        guard !rawText.isEmpty else {
            return ParsedIngredient(
                rawText: rawText,
                name: "",
                parseStatus: .needsReview
            )
        }

        if let parsedNonNumeric = parseNonNumericAmount(rawText: rawText, parseText: parseText) {
            return parsedNonNumeric
        }

        if let parsedRange = parseRange(rawText: rawText, parseText: parseText) {
            return parsedRange
        }

        if let parsedSingleAmount = parseSingleAmount(rawText: rawText, parseText: parseText) {
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

    private func parseNonNumericAmount(rawText: String, parseText: String) -> ParsedIngredient? {
        let text = removingTrailingNote(from: parseText)

        for amountText in nonNumericAmountTexts {
            guard text.hasSuffix(amountText) else {
                continue
            }

            let name = text
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

    private func parseRange(rawText: String, parseText: String) -> ParsedIngredient? {
        let text = removingTrailingNote(from: parseText)
        let pattern = "^(.+?)\\s*\(amountPattern)\\s*[~-]\\s*\(amountPattern)\\s*\(unitPattern)?$"
        guard let match = firstMatch(pattern: pattern, in: text) else {
            return nil
        }

        let name = match[1].trimmingCharacters(in: .whitespacesAndNewlines)
        let lowerText = match[2]
        let upperText = match[3]
        let unit = normalizedUnit(match[safe: 4])

        guard
            !name.isEmpty,
            let lowerValue = IngredientAmountValueParser.numericValue(from: lowerText),
            let upperValue = IngredientAmountValueParser.numericValue(from: upperText)
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

    private func parseSingleAmount(rawText: String, parseText: String) -> ParsedIngredient? {
        let text = removingTrailingNote(from: parseText)
        let pattern = "^(.+?)\\s*\(amountPattern)\\s*\(unitPattern)?$"
        guard let match = firstMatch(pattern: pattern, in: text) else {
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
            amountValue: IngredientAmountValueParser.numericValue(from: amountText),
            amountUpperValue: nil,
            unit: unit,
            parseStatus: .parsed
        )
    }

    private func normalizedUnit(_ unit: String?) -> String? {
        guard let unit, !unit.isEmpty else {
            return nil
        }

        let lowercaseUnit = unit.lowercased()

        if ["g", "kg", "ml"].contains(lowercaseUnit) {
            return lowercaseUnit
        }

        if ["그램", "그람"].contains(unit) {
            return "g"
        }

        if ["킬로그램", "킬로", "키로"].contains(unit) {
            return "kg"
        }

        if ["밀리리터", "밀리", "미리"].contains(unit) {
            return "ml"
        }

        if unit == "리터" {
            return "L"
        }

        if lowercaseUnit == "l" {
            return "L"
        }

        return unit
    }

    private func normalizedParseText(from rawText: String) -> String {
        let bulletPattern = "^\\s*(?:[-*•·]\\s+|\\d+[.)]\\s+)"
        return replacingFirstMatch(pattern: bulletPattern, in: rawText, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func removingTrailingNote(from text: String) -> String {
        let trailingNotePattern = "\\s*(?:\\([^)]*\\)|\\[[^\\]]*\\])\\s*$"
        return replacingFirstMatch(pattern: trailingNotePattern, in: text, with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func firstMatch(pattern: String, in text: String) -> [String]? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
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

    private func replacingFirstMatch(pattern: String, in text: String, with replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return text
        }

        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, range: range) else {
            return text
        }

        return regex.stringByReplacingMatches(
            in: text,
            range: match.range,
            withTemplate: replacement
        )
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
