//
//  ViewController.swift
//  JustPublisher
//
//  Created by Gabriel on 24/11/21.
//

import UIKit
import Combine

struct User: Codable {
    let name: String
}

class ViewController: UIViewController, UITableViewDataSource {
  
    
    let url = URL(string: "https://jsonplaceholder.typicode.com/users")
    var observer: AnyCancellable?
    private var users: [User] = []
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        observer = fetchUsers()
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] users in
                self?.users = users
                self?.tableView.reloadData()
            })
    }

     
    func fetchUsers() -> AnyPublisher<[User], Never> {
        guard let url = url else { return Just([]).eraseToAnyPublisher() }
    
    let publisher = URLSession.shared.dataTaskPublisher(for: url)
        .map({ $0.data })
        .decode(type: [User].self, decoder: JSONDecoder())
        .catch({ _ in
            Just([])
        })
        .eraseToAnyPublisher()
        
    return publisher
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].name
        return cell

    }
    
}

