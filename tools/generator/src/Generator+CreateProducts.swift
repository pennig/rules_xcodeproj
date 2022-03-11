import PathKit
import XcodeProj

extension Generator {
    static func createProducts(
        in pbxProj: PBXProj,
        for targets: [TargetID: Target]
    ) -> (Products, PBXGroup) {
        var products = Products()
        for (id, target) in targets {
            guard let productPath = target.product.path else {
                products.add(
                    product: nil,
                    for: .init(target: id, path: nil)
                )
                continue
            }

            let product = PBXFileReference(
                sourceTree: .buildProductsDir,
                explicitFileType: target.product.type.fileType,
                path: productPath.lastComponent,
                includeInIndex: false
            )
            pbxProj.add(object: product)
            products.add(
                product: product,
                for: .init(target: id, path: productPath)
            )
        }

        let group = PBXGroup(
            children: products.byTarget.sortedLocalizedStandard(),
            sourceTree: .group,
            name: "Products"
        )
        pbxProj.add(object: group)
        pbxProj.rootObject?.productsGroup = group

        return (products, group)
    }
}

struct Products: Equatable {
    struct ProductKeys: Equatable, Hashable {
        let target: TargetID
        let path: Path?
    }

    private(set) var byTarget: [TargetID: PBXFileReference?] = [:]
    private(set) var byPath: [Path: PBXFileReference] = [:]

    mutating func add(
        product: PBXFileReference?,
        for keys: ProductKeys
    ) {
        byTarget[keys.target] = product
        if let path = keys.path, let product = product {
            byPath[path] = product
        }
    }
}

extension Products {
    init(_ products: [ProductKeys: PBXFileReference?]) {
        for (keys, product) in products {
            byTarget[keys.target] = product
            if let path = keys.path, let product = product {
                byPath[path] = product
            }
        }
    }
}
