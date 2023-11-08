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
        register(
            cellClass,
            forCellWithReuseIdentifier: cellClass.reuseIdentifier)
    }
    
    public func dequeueReusableCell<C: UICollectionViewReusable>(
        ofType cellClass: C.Type,
        for indexPath: IndexPath
    ) -> C where C: UICollectionViewCell {
        guard
            let cell = dequeueReusableCell(
                withReuseIdentifier: cellClass.reuseIdentifier,
                for: indexPath) as? C
        else {
            preconditionFailure("""
                Unable to dequeue the collection view cell of type \(cellClass) \
                with reuse identifier \(cellClass.reuseIdentifier). \
                Didn't you forget to register it?
                """)
        }
        
        return cell
    }
    
    public func registerSupplementaryView<V: UICollectionReusableView>(
        ofType viewClass: V.Type,
        kind: SupplementaryViewKind
    ) where V: UICollectionViewReusable {
        register(
            viewClass,
            forSupplementaryViewOfKind: kind.stringValue(),
            withReuseIdentifier: viewClass.reuseIdentifier)
    }
    
    public func dequeueSupplementaryView<V: UICollectionViewReusable>(
        ofType viewClass: V.Type,
        kind: SupplementaryViewKind,
        for indexPath: IndexPath
    ) -> V where V: UICollectionReusableView {
        guard
            let view = dequeueReusableSupplementaryView(
                ofKind: kind.stringValue(),
                withReuseIdentifier: viewClass.reuseIdentifier,
                for: indexPath) as? V
        else {
            preconditionFailure("""
                Unable to dequeue the collection view supplementary view of type \(viewClass) \
                with reuse identifier \(viewClass.reuseIdentifier). \
                Didn't you forget to register it?
                """)
        }
        
        return view
    }
}
