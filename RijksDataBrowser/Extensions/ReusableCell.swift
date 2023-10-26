//
//  ReusableCell.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 25/10/2023.
//

import UIKit

public protocol ReusableCell {
    static var reuseIdentifier: String { get }
}

extension ReusableCell {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

//extension UITableViewCell: ReusableCell {}
extension UICollectionViewCell: ReusableCell {}

// swiftlint:disable force_cast
//extension UITableView {
//    public func dequeueReusableCell<C: ReusableCell>(ofType cellClass: C.Type, for indexPath: IndexPath) -> C {
//        return dequeueReusableCell(withIdentifier: cellClass.reuseIdentifier, for: indexPath) as! C
//    }
//}

extension UICollectionView {
    public func dequeueReusableCell<C: ReusableCell>(ofType cellClass: C.Type, for indexPath: IndexPath) -> C {
        return dequeueReusableCell(withReuseIdentifier: cellClass.reuseIdentifier, for: indexPath) as! C
    }
    
    public func registerReusableCell<C: UICollectionViewCell>(ofType cellClass: C.Type) where C: ReusableCell {
        self.register(cellClass, forCellWithReuseIdentifier: cellClass.reuseIdentifier)
    }
}
