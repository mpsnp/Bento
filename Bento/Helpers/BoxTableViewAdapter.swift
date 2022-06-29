@_exported import UIKit

/// - Warning: When you use `BoxTableViewAdapter` your `tableView.render(box)` cannot be invoked in `viewWillAppear`. We suggest to call it in
/// `viewDidAppear`. UIKit changes UITableView's `layoutMargins` in between `viewWillAppear` & `viewDidAppear`. The UITableView's `layoutMargins` is used
/// in the BoxTableViewAdapter's implementation.
public final class BoxTableViewAdapter<SectionId: Hashable, RowId: Hashable>
    : TableViewAdapterBase<SectionId, RowId>,
      UITableViewDataSource,
      UITableViewDelegate {
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        copyLayoutMargins(from: tableView, to: cell.contentView)
        return cell
    }

    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let view = super.tableView(tableView, viewForHeaderInSection: section) {
            let view = unsafeDowncast(view, to: UITableViewHeaderFooterView.self)
            copyLayoutMargins(from: tableView, to: view.contentView)
            return view
        }
        return nil
    }

    override public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let view = super.tableView(tableView, viewForFooterInSection: section) {
            let view = unsafeDowncast(view, to: UITableViewHeaderFooterView.self)
            copyLayoutMargins(from: tableView, to: view.contentView)
            return view
        }
        return nil
    }

    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = sections[indexPath.section].items[indexPath.row]
            .component(as: HeightCustomizing.self)
            .map { component in
                return component.height(forWidth: tableView.bounds.width,
                                        inheritedMargins: tableView.layoutMargins.horizontal)
                    + tableView.separatorHeight
            }
        return height ?? super.tableView(tableView, heightForRowAt: indexPath)
    }

    override public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let height = sections[section]
            .component(of: .header, as: HeightCustomizing.self)
            .map { component in
                return component.height(forWidth: tableView.bounds.width,
                                        inheritedMargins: tableView.layoutMargins.horizontal)
            }
        return height ?? super.tableView(tableView, heightForHeaderInSection: section)
    }

    override public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let height = sections[section]
            .component(of: .footer, as: HeightCustomizing.self)
            .map { component in
                return component.height(forWidth: tableView.bounds.width,
                                        inheritedMargins: tableView.layoutMargins.horizontal)
        }
        return height ?? super.tableView(tableView, heightForFooterInSection: section)
    }

    override public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = sections[indexPath.section].items[indexPath.row]
            .component(as: HeightCustomizing.self)
            .map { component in
                return component.estimatedHeight(forWidth: tableView.bounds.width,
                                                 inheritedMargins: tableView.layoutMargins.horizontal)
            }
        return height ?? super.tableView(tableView, estimatedHeightForRowAt: indexPath)
    }

    override public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        let height = sections[section]
            .component(of: .header, as: HeightCustomizing.self)
            .map { component in
                return component.height(forWidth: tableView.bounds.width,
                                        inheritedMargins: tableView.layoutMargins.horizontal)
            }
        return height ?? super.tableView(tableView, estimatedHeightForHeaderInSection: section)
    }

    override public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        let height = sections[section]
            .component(of: .footer, as: HeightCustomizing.self)
            .map { component in
                return component.height(forWidth: tableView.bounds.width,
                                        inheritedMargins: tableView.layoutMargins.horizontal)
            }
        return height ?? super.tableView(tableView, estimatedHeightForFooterInSection: section)
    }

    private func copyLayoutMargins(from tableView: UITableView, to view: UIView) {
        view.preservesSuperviewLayoutMargins = false
        view.layoutMargins = UIEdgeInsets(top: 0,
                                          left: tableView.layoutMargins.left,
                                          bottom: 0,
                                          right: tableView.layoutMargins.right)
    }
}

extension UITableView {
    fileprivate var separatorHeight: CGFloat {
        return separatorStyle != .none ? 1.0 / contentScaleFactor : 0.0
    }
}
