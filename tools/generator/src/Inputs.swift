struct Inputs: Equatable {
    let srcs: Set<FilePath>
    let nonArcSrcs: Set<FilePath>
    let hdrs: Set<FilePath>
    let resources: Set<FilePath>

    init(
        srcs: Set<FilePath> = [],
        nonArcSrcs: Set<FilePath> = [],
        hdrs: Set<FilePath> = [],
        resources: Set<FilePath> = []
    ) {
        self.srcs = srcs
        self.nonArcSrcs = nonArcSrcs
        self.hdrs = hdrs
        self.resources = resources
    }
}

extension Inputs {
    var all: Set<FilePath> {
        return srcs
            .union(nonArcSrcs)
            .union(hdrs)
            .union(resources)
    }
}

// MARK: - Decodable

extension Inputs: Decodable {
    enum CodingKeys: String, CodingKey {
        case srcs
        case nonArcSrcs
        case hdrs
        case resources
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        srcs = try container.decodeFilePaths(.srcs)
        nonArcSrcs = try container.decodeFilePaths(.nonArcSrcs)
        hdrs = try container.decodeFilePaths(.hdrs)
        resources = try container.decodeFilePaths(.resources)
    }
}

private extension KeyedDecodingContainer where K == Inputs.CodingKeys {
    func decodeFilePaths(_ key: K) throws -> Set<FilePath> {
        return try decodeIfPresent(Set<FilePath>.self, forKey: key) ?? []
    }
}
