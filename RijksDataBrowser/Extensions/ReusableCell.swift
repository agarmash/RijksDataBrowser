//
//  ReusableCell.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 25/10/2023.
//

import UIKit

public protocol UICollectionViewReusable {
    static var reuseIdentifier: String { get }
}

extension UICollectionViewReusable {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionReusableView: UICollectionViewReusable {}

extension UICollectionView {
    public enum SupplementaryViewKind {
        case header
        case footer
        
        func stringValue() -> String {
            switch self {
            case .header:
                return UICollectionView.elementKindSectionHeader
            case .footer:
                return UICollectionView.elementKindSectionFooter
            }
        }
    }
    
    public func registerReusableCell<C: UICollectionViewCell>(
        ofType cellClass: C.Type
    ) where C: UICollectionViewReusable {
        self.register(
            cellClass,
            forCellWithReuseIdentifier: cellClass.reuseIdentifier)
    }
    
    public func dequeueReusableCell<C: UICollectionViewReusable>(
        ofType cellClass: C.Type,
        for indexPath: IndexPath
    ) -> C where C: UICollectionViewCell {
        return dequeueReusableCell(
            withReuseIdentifier: cellClass.reuseIdentifier,
            for: indexPath) as! C
    }
    
    public func registerSupplementaryView<V: UICollectionReusableView>(
        ofType viewClass: V.Type,
        kind: SupplementaryViewKind
    ) where V: UICollectionViewReusable {
        self.register(
            viewClass,
            forSupplementaryViewOfKind: kind.stringValue(),
            withReuseIdentifier: viewClass.reuseIdentifier)
    }
    
    public func dequeueSupplementaryView<V: UICollectionViewReusable>(
        ofType viewClass: V.Type,
        kind: SupplementaryViewKind,
        for indexPath: IndexPath
    ) -> V where V: UICollectionReusableView {
        return dequeueReusableSupplementaryView(
            ofKind: kind.stringValue(),
            withReuseIdentifier: viewClass.reuseIdentifier,
            for: indexPath) as! V
    }
}
