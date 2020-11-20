//
//  TableView.swift
//  demo
//
//  Created by Laurent Grandhomme on 10/19/16.
//  Copyright © 2016 Laurent Grandhomme. All rights reserved.
//

import UIKit

extension UITableView {
    func registerClass(_ cls: AnyClass) {
        self.register(cls, forCellReuseIdentifier: NSStringFromClass(cls))
    }
}

protocol TableViewCellModelProtocol {
    // should select
    func shouldSelect() -> Bool
    // did select
    func didSelect()
    // swiped to delete
    func canBeDeleted() -> Bool
    // swiped to delete
    func didGetSwiped()
    // will display
    func willDisplayCell(_ cell: UITableViewCell)
    // configure the cell
    func configuredCell(tableView: UITableView, forIndexPath indexPath: IndexPath) -> UITableViewCell
    // cell size
    func cellHeight() -> CGFloat
}

protocol TableViewCellProtocol {
    associatedtype M
    func configure(_ model: M)
    static func heightForModel(_ model: M) -> CGFloat
}

struct TableViewCellModel<T> : TableViewCellModelProtocol where T: UITableViewCell, T: TableViewCellProtocol {
    let model : T.M
    let onDisplayCellBlock : (() -> ())?
    let onSelectBlock : (() -> ())?
    let onSwipeToDeleteBlock : (() -> ())?
    let canBeSelected : Bool
    let cellIdentifier = NSStringFromClass(T.self)
    
    init(model: T.M, canBeSelected: Bool, onSelect: (() -> ())?, onDisplay: (() -> ())?, onSwipeToDelete: (() -> ())?) {
        self.model = model
        self.onDisplayCellBlock = onDisplay
        self.onSelectBlock = onSelect
        self.canBeSelected = canBeSelected
        self.onSwipeToDeleteBlock = onSwipeToDelete
    }
    init(model: T.M) {
        self.init(model: model, canBeSelected: false, onSelect: nil, onDisplay: nil, onSwipeToDelete: nil)
    }
    init(model: T.M, onSelect: @escaping () -> ()) {
        self.init(model: model, canBeSelected: true, onSelect: onSelect, onDisplay: nil, onSwipeToDelete: nil)
    }
    
    init(model: T.M, onDisplay: @escaping () -> ()) {
        self.init(model: model, canBeSelected: false, onSelect: nil, onDisplay: onDisplay, onSwipeToDelete: nil)
    }
    init(model: T.M, onSelect: @escaping () -> (), onDisplay: (() -> ())?) {
        self.init(model: model, canBeSelected: true, onSelect: onSelect, onDisplay: onDisplay, onSwipeToDelete: nil)
    }
    
    func configuredCell(tableView: UITableView, forIndexPath indexPath: IndexPath) -> UITableViewCell {
        // TODO: should we pass in the index path?
        let cell = tableView.dequeueReusableCell(withIdentifier: self.cellIdentifier) as! T
        cell.configure(self.model)
        cell.selectionStyle = self.canBeSelected ? .default : .none
        return cell
    }
    func willDisplayCell(_ cell: UITableViewCell) {
        if let block = self.onDisplayCellBlock {
            block()
        }
    }
    func didSelect() {
        if let block = self.onSelectBlock {
            block()
        }
    }
    func shouldSelect() -> Bool {
        return self.canBeSelected
    }
    
    func cellHeight() -> CGFloat {
        return T.heightForModel(model)
    }
    
    func canBeDeleted() -> Bool {
        if let _ = self.onSwipeToDeleteBlock {
            return true
        }
        return false
    }
    
    func didGetSwiped() {
        if let block = self.onSwipeToDeleteBlock {
            block()
        }
    }
}

struct TableViewSectionModel {
    var title : String?
    
    init(title: String?, models: [TableViewCellModelProtocol]) {
        self.title = title
        self.cellModels = models
    }
    
    init() {
        self.title = nil
        self.cellModels = [TableViewCellModelProtocol]()
    }
    
    var cellModels : [TableViewCellModelProtocol]
    
    func numberOfItems() -> Int {
        return self.cellModels.count
    }
    
    func modelForRow(_ row: Int) -> TableViewCellModelProtocol {
        return self.cellModels[row]
    }
}


class TableViewDataSource : NSObject, UITableViewDelegate, UITableViewDataSource {
    private var sections : [TableViewSectionModel] = [TableViewSectionModel]()
    
    override init() {
        
    }
    
    init(sections: [TableViewSectionModel]) {
        self.sections = sections
    }
    
    init(section: TableViewSectionModel) {
        self.sections = [section]
    }
    
    func setSingleSection(title: String? = nil, models: [TableViewCellModelProtocol]) {
        self.sections = [TableViewSectionModel(title: title, models: models)]
    }
    
    func modelForIndexPath(_ indexPath: IndexPath) -> TableViewCellModelProtocol {
        return self.sections[indexPath.section].modelForRow(indexPath.row)
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
        let model = modelForIndexPath(indexPath)
        return model.configuredCell(tableView: tableView, forIndexPath: indexPath)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let model = modelForIndexPath(indexPath)
        return model.canBeDeleted()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let model = modelForIndexPath(indexPath)
        model.didGetSwiped()
    }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = modelForIndexPath(indexPath)
        return model.cellHeight()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = modelForIndexPath(indexPath)
        model.didSelect()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let model = modelForIndexPath(indexPath)
        model.willDisplayCell(cell)
    }
}

