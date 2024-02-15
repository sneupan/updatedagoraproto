//
//  ViewController.swift
//  agoraproto
//
//  Created by Saskriti Neupane  on 2/1/24.
//


import UIKit

class ControllerView: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    var events = [Event]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        loadData()
    }

    func loadData() {
        guard let url = URL(string: "YOUR_API_ENDPOINT") else {
            print("Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error: Invalid HTTP response")
                return
            }

            guard let jsonData = data else {
                print("Error: No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                let topLevelData = try decoder.decode([TopLevelObject].self, from: jsonData)
                let eventsData = topLevelData.flatMap { $0.events }
                DispatchQueue.main.async {
                    self?.events = eventsData
                    self?.tableView.reloadData()
                }

            } catch {
                print("Error decoding JSON: \(error)")
            }

        }

        task.resume()

    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let event = events[indexPath.row]
        cell.textLabel?.text = event.name
        return cell

    }

}

