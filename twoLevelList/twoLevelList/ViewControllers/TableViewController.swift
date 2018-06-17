//
//  TableViewController.swift
//  twoLevelList
//
//  Created by Maksym on 6/15/18.
//  Copyright © 2018 Maksym. All rights reserved.
//

import UIKit
import Alamofire

class TableViewController: UITableViewController {

    var data = header()
    var last = [Int]()
    var Path = IndexPath()
    var refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Test Case"
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(TableViewController.refreshData), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        refreshData()
    }

    @objc func refreshData()
    {
        guard let url = URL(string: "https://demo8139132.mockable.io/list") else { return }
        Alamofire.request(url).responseJSON
            {
                response in
                guard response.result.isSuccess else
                {
                    print("Ошибка при запросе данных \(String(describing: response.result.error))")
                    return
                }
                guard let json = response.data else { return }
                do
                {
                    let decoder = JSONDecoder()
                    self.data = try decoder.decode(header.self, from: json)
                    self.tableView.reloadData()
                    self.refresher.endRefreshing()
                }
                catch let err
                {
                    print("err ", err)
                    return
                }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let count = data.response?.count
        {
            return (count)
        }
        return (0)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if var parent = data.response
        {
            if parent[section].opened == true
            {
                if let child = parent[section].children
                {
                    return (child.count + 1)
                }
            } else {
                return (1)
            }
        }
        return (1)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0
        {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
            cell.textLabel?.text = data.response![indexPath.section].name
            cell.backgroundColor = UIColor.darkGray
            cell.textLabel?.textColor = UIColor.white
            if !(data.response![indexPath.section].children?.isEmpty)!
            {
                cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
            return (cell)
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
            cell.textLabel?.text = data.response![indexPath.section].children![indexPath.row - 1].name
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textColor = UIColor.black
            cell.accessoryType = UITableViewCellAccessoryType.none
            if (last.count == 2 && indexPath.section == last[0] && indexPath.row - 1 == last[1])
            {
                cell.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            return (cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
            if (last.count == 2)
            {
                Path = IndexPath(row: last[1] + 1, section: last[0])
                tableView.cellForRow(at: Path)?.accessoryType = UITableViewCellAccessoryType.checkmark
                data.response![last[0]].children![last[1]].marked = true
            }
            if data.response![indexPath.section].opened == true
            {
                data.response![indexPath.section].opened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                data.response![indexPath.section].opened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        }
        else
        {

            if data.response![indexPath.section].children![indexPath.row - 1].marked == true
            {
                last.removeAll()
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
                data.response![indexPath.section].children![indexPath.row - 1].marked = false
            }
            else
            {
                if (last.count == 2)
                {
                    Path = IndexPath(row: last[1] + 1, section: last[0])
                    tableView.cellForRow(at: Path)?.accessoryType = UITableViewCellAccessoryType.none
                    data.response![last[0]].children![last[1]].marked = false
                    last.removeAll()
                }
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
                data.response![indexPath.section].children![indexPath.row - 1].marked = true
                last.append(indexPath.section)
                last.append(indexPath.row - 1)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        last.removeAll()
        if (data.response![indexPath.section].children![indexPath.row - 1].marked == false)
        {
            return
        }
        data.response![indexPath.section].children![indexPath.row - 1].marked = false
        last.append(indexPath.section)
        last.append(indexPath.row - 1)
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
    }
    
    func checkSection(indPath: IndexPath)
    {
        if (last.count == 2 && indPath.section < last[0])
        {
            last[0] -= 1
        }
        else if (last.count == 2 && indPath.section == last[0])
        {
            last.removeAll()
        }
    }
    
    func checkCell(indPath: IndexPath)
    {
        if (last.count == 2 && indPath.section == last[0])
        {
            if (indPath.row - 1 == last[1] || (indPath.row - 1 == 0 && last[1] == 0))
            {
                last.removeAll()
            }
            else if (indPath.row - 1 <= last[1])
            {
                last[1] -= 1
            }
        }
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "🗑\nDelete") { (action, view, completion) in
            if indexPath.row == 0
            {
                self.data.response!.remove(at: indexPath.section)
                self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
                self.checkSection(indPath: indexPath)
            } else {
                self.data.response![indexPath.section].children!.remove(at: indexPath.row - 1)
                if (self.data.response![indexPath.section].children?.isEmpty)!
                {
                    self.Path = IndexPath(row: 0, section: indexPath.section)
                    self.tableView.cellForRow(at: self.Path)?.accessoryType = UITableViewCellAccessoryType.none
                }
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.checkCell(indPath: indexPath)
            }
            completion(true)
        }
        action.backgroundColor = UIColor.red
        return (action)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return (UISwipeActionsConfiguration(actions: [delete]))
    }
}
