//
//  StringExtensions.swift 
//
//  Created by Thanh Vu on 12/02/2021.
//  Copyright © 2020 thanhvu. All rights reserved.
//

import Foundation

public extension String {
  subscript(value: Int) -> Character {
    self[index(at: value)]
  }
}

public extension String {
  subscript(value: NSRange) -> String {
    return String(self[value.lowerBound..<value.upperBound])
  }
}

public extension String {
  subscript(value: CountableClosedRange<Int>) -> Substring {
    self[index(at: value.lowerBound)...index(at: value.upperBound)]
  }

  subscript(value: CountableRange<Int>) -> Substring {
    self[index(at: value.lowerBound)..<index(at: value.upperBound)]
  }

  subscript(value: PartialRangeUpTo<Int>) -> Substring {
    self[..<index(at: value.upperBound)]
  }

  subscript(value: PartialRangeThrough<Int>) -> Substring {
    self[...index(at: value.upperBound)]
  }

  subscript(value: PartialRangeFrom<Int>) -> Substring {
    self[index(at: value.lowerBound)...]
  }
}

private extension String {
  func index(at offset: Int) -> String.Index {
    index(startIndex, offsetBy: offset)
  }
}

public extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(from: Int) -> String {
        if from >= self.count {
            return ""
        }

        if from < 0 {
            return self
        }

        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }

    func substring(toIndex: Int) -> String {
        if toIndex >= self.count {
            return self
        }

        if toIndex < 0 {
            return ""
        }

        let index = index(from: toIndex)
        return String(self[..<index])
    }

    func addingURLPercent() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    func encodeURLString() -> String {
        guard let url = self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return ""
        }

        return url
    }
}

public extension String {
    func localized(bundle: Bundle = Bundle.main) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: bundle, comment: self)
    }
}

public extension String {
    func matches(regex: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: regex, options: [.caseInsensitive]) else { return [] }
        let matches  = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matches.map { match in
            return String(self[Range(match.range, in: self)!])
        }
    }

    func convertToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-mm-dd"
        return dateFormatter.date(from: self) ?? Date()
    }
}
