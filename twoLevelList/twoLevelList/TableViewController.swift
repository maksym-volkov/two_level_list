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
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Test Case"
//        tableView.is
        refreshData()
    }
    
    func refreshData()
    {
        getData()
            {
                completion in
                if completion != nil
                {
                    //                print(completion!)
//                    var index = 0
//                    while (self.data.response?[index] != nil)
//                    {
//                        self.data.response![index].opened = false
//                        index += 1
//                    }
//                    for var each in self.data.response!
//                    {
//                        print(each.name!)
////                        print(each.opened!)
//                        print(each.opened)
//                        print("-----------")
//                    }
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
            }
            return (cell)
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else { return UITableViewCell() }
            cell.textLabel?.text = data.response![indexPath.section].children![indexPath.row - 1].name
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textColor = UIColor.black
            print(indexPath)
            if data.response![indexPath.section].children![indexPath.row - 1].marked == false
            {
//                print("tyt")
                cell.accessoryType = UITableViewCellAccessoryType.none
            }
            return (cell)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
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
//            tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark
            if data.response![indexPath.section].children![indexPath.row].marked == true
            {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
                data.response![indexPath.section].children![indexPath.row].marked = false
            }
            else
            {
                tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
                data.response![indexPath.section].children![indexPath.row].marked = true
            }
        }
    }
}
