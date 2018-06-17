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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Test Case"
        refreshData()
    }
    
    func refreshData()
    {
        getData()
            {
                completion in
                if completion != nil
                {
                    self.tableView.reloadData()
                }
                else
                {}
        }
    }
    
    func getData(completion: @escaping (String?) -> Void)
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
                    completion("download finished")
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
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("tyt")
        print(indexPath)
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
}
