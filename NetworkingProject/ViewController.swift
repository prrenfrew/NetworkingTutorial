//
//  ViewController.swift
//  NetworkingProject
//
//  Created by MAC on 12/8/20.
//

import UIKit

/*
 TableView with API optimizations
 
 1. Only get the data for the cells we want to show(This includes images!)
 2. Cache Images, so that we don't have to always make an API call to get image data
 3. When working with paginated APIs, only get first page, then load subsequent pages as needed based on how far the user scrolls down
 */

/*
 Network Status codes
 100 - Informational
 200 - was successful and everything is good
 300 - was successful, but resource is somewhere else
 400 - client-side error
 403 - Forbidden
 404 - not found
 500 - server-side error
 */

/*
 Multithreading in iOS
 2 first party approaches
 1. GCD = Grand Central Dispatch - low level C library for multithreading
 2. NSOperations - Built on top of GCD, and provides us with extra functionality, such as pausing, resuming, adding dependencies
 */

/*
 Updating UI on background thread
 
 This has undefined behavior. In general 1 of 3 things will happen(we don't know which one)
 
 1. The update is delayed, but nothing outside of that.
 2. The UI update never happens
 3. It will crash the app
 */

class ViewController: UIViewController {

  @IBOutlet weak var pokemonTableView: UITableView!
  @IBOutlet weak var pokemonImageView: UIImageView?
  @IBOutlet weak var pokemonNameLabel: UILabel?
  
  var pokemonArray: [Pokemon] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.pokemonTableView.register(UINib(nibName: "PokemonTableViewCell", bundle: nil), forCellReuseIdentifier: "PokemonTableViewCell")
    self.pokemonTableView.dataSource = self
    self.pokemonTableView.prefetchDataSource = self
//    self.getSingularPokemon()
//    self.getSixPokemon()
  }
  
  private func getSixPokemon() {
    
    
    let group = DispatchGroup()
    for _ in 1...20 {
      group.enter()
      NetworkingManager.shared.getDecodedObject(from: self.createRandomPokemonURL()) { (pokemon: Pokemon?, error) in
        guard let pokemon = pokemon else { return }
        self.pokemonArray.append(pokemon)
        group.leave()
      }
    }
    group.notify(queue: .main) {
      self.pokemonTableView.reloadData()
    }
  }
  
  private func getSingularPokemon() {
    NetworkingManager.shared.getDecodedObject(from: self.createRandomPokemonURL()) { (pokemon: Pokemon?, error) in
      guard let pokemon = pokemon else {
        if let error = error {
          let alert = self.generateAlert(from: error)
          DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
          }
        }
        return
      }
      DispatchQueue.main.async {
        self.pokemonNameLabel?.text = pokemon.name
      }
      NetworkingManager.shared.getImageData(from: pokemon.frontImageURL) { data, error in
        guard let data = data else { return }
        DispatchQueue.main.async {
          self.pokemonImageView?.image = UIImage(data: data)
        }
      }
    }
  }
  
  private func createRandomPokemonURL() -> String {
    let randomNumber = Int.random(in: 1...151)
    return "https://pokeapi.co/api/v2/pokemon/\(randomNumber)"
  }
  
  private func generateAlert(from error: Error) -> UIAlertController {
    let alert = UIAlertController(title: "Error", message: "We ran into an error! Error Description: \(error.localizedDescription)", preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
    alert.addAction(okAction)
    return alert
  }
}

extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.pokemonArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonTableViewCell", for: indexPath) as! PokemonTableViewCell
    cell.configure(with: self.pokemonArray[indexPath.row])
    return cell
  }
}

extension ViewController: UITableViewDataSourcePrefetching {
  func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
    let lastIndex = IndexPath(row: self.pokemonArray.count - 1, section: 0)
    guard indexPaths.contains(lastIndex) else { return }
    self.getSixPokemon()
  }
}

/*
 Dispatch Queues
 
 There are 2 queues defined for us:
 
 1. main
 2. global()//can also be referred to as the background thread
 
 Disaptch queues can also have a priority
 1. UserInteractive
 2. UserInitiated
 3. Default
 4. Background
 5. Utility
 6. Unspecified
 
 
 There are 2 types of DispatchQueues:
 
 1. serial - does one thing at a time. Main is an example of a serial queue
 2. Concurrent - can do multiple things at the same time. Global is an example of a concurrent disaptch queue
 
 You can do work on a dispatch queue in 2 different ways
 
 1. sync - tells the previous queue to wait for us to finish. Once the work has finished, then we continue
 2. async - basically does the work eventually, so we don't know exactly when it will, but it will do it eventually
 */
