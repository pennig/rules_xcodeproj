import XcodeProj

private extension PBXFileElement {
    var sortOrder: Int {
        switch self {
        case is PBXGroup:
            return -1
        default:
            return 0
        }
    }

    var namePathSortString: String {
        "\(name ?? path ?? "")\t\(name ?? "")\t\(path ?? "")"
    }
}

extension Sequence {
    static func sortByLocalizedStandard(
        _ keyPath: KeyPath<Element, String>
    ) -> (
        _ lhs: Element,
        _ rhs: Element
    ) -> Bool {
        return { lhs, rhs in
            let l = lhs[keyPath: keyPath]
            let r = rhs[keyPath: keyPath]
            return l.localizedStandardCompare(r) == .orderedAscending
        }
    }

    func sortedLocalizedStandard(
        _ keyPath: KeyPath<Element, String>
    ) -> [Element] {
        return self.sorted(by: Self.sortByLocalizedStandard(keyPath))
    }
}

extension Sequence where Element == String {
    func sortedLocalizedStandard() -> [Element] {
        return sortedLocalizedStandard(\.self)
    }
}

extension Sequence where Element: PBXFileElement {
    func sortedLocalizedStandard() -> [Element] {
        return sortedLocalizedStandard(\.namePathSortString)
    }
}

extension Sequence where Element == PBXBuildFile {
    func sortedLocalizedStandard() -> [Element] {
        return sortedLocalizedStandard(\.file!.namePathSortString)
    }
}

extension Array where Element: PBXFileElement {
    mutating func sortGroupedLocalizedStandard() {
        let fileSort = Self.sortByLocalizedStandard(\.namePathSortString)
        self.sort { lhs, rhs in
            let lhsSortOrder = lhs.sortOrder
            let rhsSortOrder = rhs.sortOrder
            if lhsSortOrder != rhsSortOrder {
                // Groups before files
                return lhsSortOrder < rhsSortOrder
            } else {
                // Files alphabetically
                return fileSort(lhs, rhs)
            }
        }
        for element in self {
            if let group = element as? PBXGroup {
                group.children.sortGroupedLocalizedStandard()
            }
        }
    }
}

private struct PBXFileReferenceByTargetID {
    let targetID: TargetID
    let file: PBXFileReference

    init(targetID: TargetID, file: PBXFileReference) {
        self.targetID = targetID
        self.file = file
    }

    var sortString: String {
        return "\(file.namePathSortString)\t\(targetID)"
    }
}

extension Dictionary where Key == TargetID, Value == PBXFileReference? {
    func sortedLocalizedStandard() -> [PBXFileReference] {
        let sort = [PBXFileReferenceByTargetID]
            .sortByLocalizedStandard(\.sortString)
        return self
            .compactMap { key, value in
                guard let value = value else {
                    return nil
                }
                return PBXFileReferenceByTargetID(targetID: key, file: value)
            }
            .sorted(by: sort)
            .map(\.file)
    }
}
