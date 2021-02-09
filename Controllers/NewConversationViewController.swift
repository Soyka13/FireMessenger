//
//  NewConversationViewController.swift
//  Messenger
//
//  Created by Olena Stepaniuk on 07.11.2020.
//

import UIKit

class NewConversationViewController: UIViewController {
    
    public var completion: ((SearchResult) -> (Void))?
    
    private var users = [[String: String]]()
    private var results = [SearchResult]()
    private var hasFetched = false
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users..."
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewConversationCell.self, forCellReuseIdentifier: NewConversationCell.identifier)
        return table
    }()
    
    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.text = "No Results"
        label.isHidden = true
        label.textAlignment = .center
        label.textColor = .green
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = .white
        searchBar.delegate = self
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
        noResultsLabel.frame = CGRect(x: view.width/4, y: (view.height-200)/2, width: view.width, height: 200)
    }
    
    
    @objc func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewConversationCell.identifier,
                                                 for: indexPath) as! NewConversationCell
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // start conversation
        
        let targetUserData = results[indexPath.row]
        
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        searchBar.resignFirstResponder()
        
        results.removeAll()
        self.searchUsers(query: text)
    }
    
    func searchUsers(query: String) {
        // check if array has firebase results
        if hasFetched {
            // if it does: filter
            filterUsers(with: query)
        } else {
            // if not, fetch then filter
            DatabaseManager.shared.getAllUser { [weak self](result) in
                switch result {
                case .success(let usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                    print("Success")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        // update the ui: either show results or show results label
        
    }
    
    func filterUsers(with term: String) {
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            print(hasFetched)
            print("error here")
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(email: currentUserEmail)
        
        let results: [SearchResult] = users.filter({
            guard let email = $0["email"], email != safeEmail else {
                return false
            }
            
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            print(name.hasPrefix(term.lowercased()))
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            
            guard let email = $0["email"],
                  let name = $0["name"] else {
                return nil
            }
            print(name + " " + email)
            return SearchResult(name: name, email: email)
        })
        
        print(results)
        self.results = results
        
        updateUI()
    }
    
    func updateUI() {
        if results.isEmpty{
            print("Ressults empty")
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.noResultsLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
}
