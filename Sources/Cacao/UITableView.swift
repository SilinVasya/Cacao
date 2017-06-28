//
//  TableView.swift
//  Cacao
//
//  Created by Alsey Coleman Miller on 5/28/16.
//  Copyright © 2016 PureSwift. All rights reserved.
//

import Foundation
import Silica

/// A view that presents data using rows arranged in a single column.
open class UITableView: UIScrollView {
    
    // MARK: - Initialization
    
    /// Initializes and returns a table view object having the given frame and style.
    public init(frame: CGRect, style: UITableViewStyle) {
        
        // UITableView properties
        self.style = style
        
        // UIScrollView properties
        super.init(frame: frame)
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = true
        //self.alwaysBounceVertical = true
        self.bounces = true
        
        
        // UIView
        switch style {
        case .plain:
            self.backgroundColor = .white
        case .grouped:
            break
        }
    }
    
    public override convenience init(frame: CGRect) {
        
        self.init(frame: frame, style: .plain)
    }
    
    // MARK: - Providing the Table View Data
    
    /// The object that acts as the data source of the table view.
    public weak var dataSource: UITableViewDataSource?
    
    // MARK: - Customizing the Table View Behavior
    
    /// The object that acts as the delegate of the table view.
    public weak var tableViewDelegate: UITableViewDelegate?
    
    // MARK: - Configuring a Table View
    
    /// the style of the table view.
    public let style: UITableViewStyle
    
    /// Returns the number of rows (table cells) in a specified section.
    public func numberOfRows(inSection section: Int) -> Int {
        
        return dataSource?.tableView(self, numberOfRowsInSection: section) ?? 0
    }
    
    /// The number of sections in the table view.
    public var numberOfSections: Int {
        
        return dataSource?.numberOfSections(in: self) ?? 1
    }
    
    /// The height of each row (that is, table cell) in the table view.
    public var rowHeight: CGFloat = UITableView.defaultRowHeight
    
    /// The style for table cells used as separators.
    public var separatorStyle: UITableViewCellSeparatorStyle = .singleLine
    
    /// The color of separator rows in the table view.
    public var separatorColor: UIColor? = UIColor(red: 0.88, green: 0.88, blue: 0.88)
    
    /// The effect applied to table separators.
    //public var separatorEffect: UIVisualEffect?
    
    /// The background view of the table view.
    public var backgroundView: UIView? {
        
        didSet {
            
            if backgroundView !== oldValue {
                
                oldValue?.removeFromSuperview()
                
                if let backgroundView = self.backgroundView {
                    
                    insertSubview(backgroundView, at: 0)
                }
            }
        }
    }
    
    /// Specifies the default inset of cell separators.
    public var separatorInset: UIEdgeInsets = UIEdgeInsets()
    
    // MARK: - Creating Table View Cells
    
    
    
    // MARK: - Private
    
    private static let defaultRowHeight: CGFloat = 43
    
    private var cache = Cache()
    
    private var needsReload = true
    
    private func updateSectionsCache() {
        
        // remove previous headers / footers
        cache.sections.forEach {
            $0.headerView?.removeFromSuperview()
            $0.footerView?.removeFromSuperview()
        }
        
        cache.sections.removeAll()
        
        // rebuild cache
        guard let dataSource = self.dataSource else { return }
        
        // compute the heights/offsets of everything
        let defaultRowHeight = self.rowHeight
        let numberOfSections = self.numberOfSections
        
        for sectionIndex in 0 ..< numberOfSections {
            
            let numberOfRowsInSection = self.numberOfRows(inSection: sectionIndex)
            
            var section = Section()
            section.headerTitle = dataSource.tableView(self, titleForHeaderInSection: sectionIndex)
            section.footerTitle = dataSource.tableView(self, titleForFooterInSection: sectionIndex)
            section.headerHeight = tableViewDelegate?.tableView(self, heightForHeaderInSection: sectionIndex) ?? self.sectionHeaderHeight
            section.footerHeight = tableViewDelegate?.tableView(self, heightForFooterInSection: sectionIndex) ?? self.sectionFooterHeight
            
            if section.headerHeight > 0, let view = tableViewDelegate?.tableView(self, viewForHeaderInSection: sectionIndex) {
                section.headerView = view
            }
            if section.footerHeight > 0, let view = tableViewDelegate?.tableView(self, viewForFooterInSection: sectionIndex) {
                section.footerView = view
            }
            
            // default section header view
            if section.headerView == nil, section.headerHeight > 0, let headerTitle = section.headerTitle {
                section.headerView = SectionLabel(title: headerTitle)
            }
            // default section footer view
            if section.footerView == nil, section.footerHeight > 0, let footerTitle = section.footerTitle {
                section.footerView = SectionLabel(title: footerTitle)
            }
            
            if let headerView = section.headerView {
                addSubview(headerView)
            } else {
                section.headerHeight = 0
            }
            
            if let footerView = section.footerView {
                addSubview(footerView)
            } else {
                section.footerHeight = 0
            }
            
            section.rowHeights = [CGFloat](repeating: 0, count: numberOfRowsInSection)
            
            for row in 0 ..< numberOfRowsInSection {
                let rowHeight = tableViewDelegate?.tableView(self, heightForRowAt: IndexPath(row: row, in: sectionIndex)) ?? defaultRowHeight
                section.rowHeights[row] = rowHeight
            }
            
            cache.sections.append(section)
        }
    }
}

// MARK: - Supporting Types

private extension UITableView {
    
    struct Cache {
        
        var sections = [Section]()
        var cells = [UITableViewCell]()
        var reuseIdentifiers = Set<String>()
    }
    
    struct Section {
        
        var rowsHeight: CGFloat = 0.0
        var headerHeight: CGFloat = 0.0
        var footerHeight: CGFloat = 0.0
        var rowHeights = [CGFloat]()
        var headerView: UIView?
        var footerView: UIView?
        var headerTitle: String?
        var footerTitle: String?
        
        var numberOfRows: Int {
            
            return rowHeights.count
        }
        
        var sectionHeight: CGFloat {
            
            return self.rowsHeight + self.headerHeight + self.footerHeight
        }
    }
    
    class SectionLabel: UILabel {
        
        init(title: String) {
            super.init(frame: CGRect())
            self.font = UIFont.boldSystemFontOfSize(17)
            self.textColor = .white
            self.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8)
            //self.shadowColor = UIColor(red: (100 / 255.0), green: (105 / 255.0), blue: (110 / 255.0))
            //self.shadowOffset = CGSize(width: 0, height: 1)
        }
        
        override func draw(_ rect: CGRect?) {
            /*
            let size: CGSize = bounds.size
            UIColor(red: CGFloat(166 / 255.0), green: CGFloat(177 / 255.0), blue: CGFloat(187 / 255.0), alpha: CGFloat(1)).setFill()
            UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: 1.0))
            var startColor = UIColor(red: CGFloat(145 / 255.0), green: CGFloat(158 / 255.0), blue: CGFloat(171 / 255.0), alpha: CGFloat(1))
            var endColor = UIColor(red: CGFloat(185 / 255.0), green: CGFloat(193 / 255.0), blue: CGFloat(201 / 255.0), alpha: CGFloat(1))
            var colorSpace = CGColorSpaceCreateDeviceRGB()
            var locations: [CGFloat] = [0.0, 1.0]
            let gradientColors = [startColor.cgColor, endColor.cgColor]
            var gradient = CGGradientCreateWithColors(colorSpace, gradientColors, locations)
            UIGraphicsGetCurrentContext()?.drawLinearGradient(gradient, start: CGPoint(x: CGFloat(0.0), y: CGFloat(1.0)), end: CGPoint(x: CGFloat(0.0), y: CGFloat(size.height - 1.0)), options: [])
            UIColor(red: CGFloat(153 / 255.0), green: CGFloat(158 / 255.0), blue: CGFloat(165 / 255.0), alpha: CGFloat(1)).setFill()
            UIRectFill(CGRect(x: CGFloat(0.0), y: CGFloat(size.height - 1.0), width: CGFloat(size.width), height: CGFloat(1.0)))
             */
            super.draw(rect)
        }
    }
}

public enum UITableViewStyle: Int {
    
    case plain
    case grouped
}

public enum UITableViewScrollPosition: Int {
    
    case none
    case top
    case middle
    case bottom
}

public enum UITableViewRowAnimation: Int {
    
    case fade
    case right
    case left
    case top
    case bottom
    case none
    case middle
    
    case automatic = 100
}

// http://stackoverflow.com/questions/235120/whats-the-uitableview-index-magnifying-glass-character
public let UITableViewIndexSearch: String = "{search}"

open class UITableViewRowAction {
    
    
}

public protocol UITableViewDataSource: class {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    
    
    func numberOfSections(in tableView: UITableView) -> Int // Default is 1 if not implemented
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? // fixed font style. use custom view (UILabel) if you want something different
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String?
    
    
    // Editing
    
    // Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    
    
    // Moving/reordering
    
    // Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    
    
    // Index
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? // return list of section titles to display in section index view (e.g. "ABCD...Z#")
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int // tell table which section corresponds to section title/index (e.g. "B",1))
    
    
    // Data manipulation - insert and delete support
    
    // After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
    // Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    
    
    // Data manipulation - reorder / moving support
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
}

public extension UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return nil }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? { return nil }
    
    // Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return false }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool { return false }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? { return nil }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int { return index }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
}

public protocol UITableViewDelegate: UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int)
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int)
    
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int)
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?)
    
    func tableView(_ tableView: UITableView,
                   targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
}

public extension UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) { }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) { }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) { }
    
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) { }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return tableView.rowHeight }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { return tableView.headerHeight }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat { return tableView.footerHeight }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { return tableView.estimatedRowHeight }
    
    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat { return tableView.estimatedHeaderHeight }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat { return tableView.estimatedFooterHeight }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? { return nil }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?  { return nil }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool  { return true }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath?  { return indexPath }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? { return indexPath }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle { return .delete }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? { return nil }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? { return nil }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool { return true }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) { }
    
    func tableView(_ tableView: UITableView,
                   targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath,
                   toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath { return proposedDestinationIndexPath }
}
