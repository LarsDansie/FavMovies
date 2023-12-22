//
//  FavoritesViewController.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 11/3/22.
//

import UIKit

class FavoritesViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: UIView!
    
    private let movieController = MovieController.shared
        private var datasource: UITableViewDiffableDataSource<Int, Movie>!
        private var viewContext = PersistenceController.shared.viewContext
        
        private lazy var searchController: UISearchController = {
            let sc = UISearchController(searchResultsController: nil)
            sc.searchResultsUpdater = self
            sc.delegate = self
            sc.obscuresBackgroundDuringPresentation = false
            sc.searchBar.placeholder = "Search your favorites"
            sc.searchBar.delegate = self
            return sc
        }()
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setUpTableView()
            setUpDataSource()
            navigationItem.searchController = searchController
            fetchFavorites()
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            fetchFavorites()
        }
        
    }


    // MARK: - Private

    private extension FavoritesViewController {
        
        func setUpTableView() {
            tableView.backgroundView = backgroundView
            tableView.register(UINib(nibName: MovieTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
        }
        
        func setUpDataSource() {
            datasource = UITableViewDiffableDataSource<Int, Movie>(tableView: tableView) { tableView, indexPath, movie in
                let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier) as! MovieTableViewCell
                cell.update(with: movie) {
                    self.removeFavorite(movie)
                }
                return cell
            }
        }
        
        func fetchFavorites() {
            let fetchRequest = Movie.fetchRequest()
            let searchString = searchController.searchBar.text ?? ""
            if !searchString.isEmpty {
                let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchString)
                fetchRequest.predicate = predicate
            }
            let sortDescriptor = NSSortDescriptor(key: "favoritedAt", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            let results = try? viewContext.fetch(fetchRequest)
            applyNewSnapshot(from: results ?? [])
        }
        
        func applyNewSnapshot(from movies: [Movie]) {
            var snapshot = NSDiffableDataSourceSnapshot<Int, Movie>()
            snapshot.appendSections([0])
            snapshot.appendItems(movies)
            datasource?.apply(snapshot, animatingDifferences: true)
            tableView.backgroundView = movies.isEmpty ? backgroundView : nil
        }
        
        func removeFavorite(_ movie: Movie) {
            MovieController.shared.unFavoriteMovie(movie)
            var snapshot = datasource.snapshot()
            snapshot.deleteItems([movie])
            datasource?.apply(snapshot, animatingDifferences: true)
        }
        
    }


    // MARK: - UISearchResult Updating and UISearchControllerDelegate

    extension FavoritesViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
        
        func updateSearchResults(for searchController: UISearchController) {
            if searchController.searchBar.text?.isEmpty == true {
                fetchFavorites()
            }
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            fetchFavorites()
        }
        
    }
