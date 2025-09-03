//
//  ViewController.swift
//  PropertyList APP
//
//  Created by Droisys on 26/08/25.
//

import UIKit

class ViewController: UIViewController {
    
    
    var properties: [Property] = []
    var filteredProperties: [Property] = [] // for Search results
    var isSearching = false // Search active or not
    
    // Search components
    private var searchController: UISearchController!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
        
        
        setupNavigationBar()
        setupSearchController()
        loadProperties()
    }
    
    
    func setupNavigationBar() {
        
        // Navigation bar title
        self.title = "Properties"
        
        let houseIcon = UIBarButtonItem(image: UIImage(systemName: "house.fill"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = houseIcon
        
        // Search button add in navigation bar
        let searchButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(searchButtonTapped)
        )
        
        // Right side in search button
        navigationItem.rightBarButtonItem = searchButton
    }
    
    func setupSearchController() {
        // Search controller create કરો
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        
        // Search bar configuration
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search properties..."
        searchController.searchBar.backgroundColor = UIColor.systemBackground
        
        // અન્ય settings
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = true
        
        // Navigation item સાથે define કરો (initially hidden)
        definesPresentationContext = true
    }
    
    @objc func searchButtonTapped() {
        // Search controller present કરો
        present(searchController, animated: true)
    }
    
    func loadProperties() {
        if let path = Bundle.main.path(forResource: "properties", ofType: "json") {
            do {
                
                //read the file
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let propertyResponse = try JSONDecoder().decode(PropertyResponse.self, from: data)
                self.properties = propertyResponse.properties
                self.filteredProperties = self.properties // all properties show
                
                // Data successfully load thayo!
                print("Total properties: \(properties.count)")
                
                // TableView reload karo
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch {
                print("Error loading JSON: \(error)")
            }
        } else {
            print("Properties.json file not found!")
        }
    }
    
    // Search functionality
    func filterProperties(searchText: String) {
        if searchText.isEmpty {
            // જો search text empty છે, તો બધા properties show કરો
            filteredProperties = properties
        } else {
            let searchWords = searchText.lowercased().components(separatedBy: " ").filter { !$0.isEmpty }
            
            filteredProperties = properties.filter { property in
                // એક પ્રોપર્ટી ત્યારે જ મેચ થશે જ્યારે તેના કોઈપણ એક ફિલ્ડ (ટાઈટલ, ડિટેલ કે પ્રાઈસ) માં બધા સર્ચ શબ્દો હોય
                let titleContainsAll = searchWords.allSatisfy { searchWord in
                    property.title.lowercased().contains(searchWord)
                }
                
                
//                let priceContainsAll = searchWords.allSatisfy { searchWord in
//                    property.price.lowercased().contains(searchWord)
//                }
                
                // જો કોઈ પણ ફિલ્ડમાં બધા શબ્દો હાજર હોય તો જ true રિટર્ન કરો
                return titleContainsAll
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

// MARK: - Search Controller Delegates
extension ViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        isSearching = true
        filterProperties(searchText: searchText)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        // જ્યારે search dismiss થાય તો બધા properties show કરો
        isSearching = false
        filteredProperties = properties
        tableView.reloadData()
    }
}

// MARK: - SearchBar Delegate
extension ViewController: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        isSearching = true
        
        // જો search bar empty છે, તો બધા properties show કરો
        if searchBar.text?.isEmpty == true {
            filteredProperties = properties
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
        
        // બધા properties વાપસ show કરો
        isSearching = false
        filteredProperties = properties
        tableView.reloadData()
        
        // Search controller dismiss કરો
        searchController.dismiss(animated: true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() //keyboard hide
    }
}

// MARK: - TableView DataSource & Delegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // જો search કરતી વખતે કોઈ results ન મળે તો "No results" દર્શાવો
        if isSearching && filteredProperties.isEmpty {
            return 1
        }
        return filteredProperties.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isSearching && filteredProperties.isEmpty {
            let cell = UITableViewCell(style: .default, reuseIdentifier: "emptyCell")
            cell.textLabel?.text = "No properties found"
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.textColor = .systemGray
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        let property = filteredProperties[indexPath.row]
        
        // Set data to cell
        cell.titleLabel.text = property.title
        
        
        
        // Load image from URL
        loadImage(from: property.image, into: cell.myImageView)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if isSearching && filteredProperties.isEmpty {
            return
        }
        
        let selectedProperty = filteredProperties[indexPath.row]
        print("Selected: \(selectedProperty.title)")
        
        // 1. Storyboard से DetailViewController को इंस्टेंशिएट करें
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "DetailVC") as? DetailViewController else { return }
        
        // Pass the selected property to the detail view controller
        detailVC.property = selectedProperty
        
        // Push the detail view controller onto the navigation stack
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Image Loading
extension ViewController {
    
    func loadImage(from urlString: String, into imageView: UIImageView) {
        
        // Placeholder image set karo
        imageView.image = UIImage(systemName: "photo")
        
        guard let url = URL(string: urlString) else { return }
        
        // Background thread ma image download karo
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Image load error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Main thread ma UI update karo
            DispatchQueue.main.async {
                imageView.image = UIImage(data: data)
            }
        }.resume()
    }
}

