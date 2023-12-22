//
//  ViewController.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 10/29/22.
//

import UIKit
import CoreData

class MovieSearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var backgroundView: UIView!
    
    private let movieController = MovieController.shared
    private var datasource: UITableViewDiffableDataSource<Int, APIMovie>!

    private lazy var searchController: UISearchController = {
        let sc = UISearchController(searchResultsController: nil)
        sc.searchResultsUpdater = self
        sc.delegate = self
        sc.obscuresBackgroundDuringPresentation = false
        sc.searchBar.placeholder = "Search a movie title"
        sc.searchBar.delegate = self
        return sc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        navigationItem.searchController = searchController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var snapshot = datasource.snapshot()
        guard !snapshot.sectionIdentifiers.isEmpty else { return }
        snapshot.reloadSections([0])
        datasource?.apply(snapshot)
    }
    
}

private extension MovieSearchViewController {
    
    func setUpTableView() {
        tableView.backgroundView = backgroundView
        setUpDataSource()
        tableView.register(UINib(nibName: MovieTableViewCell.reuseIdentifier, bundle: nil), forCellReuseIdentifier: MovieTableViewCell.reuseIdentifier)
    }
    
    func setUpDataSource() {
        datasource = UITableViewDiffableDataSource<Int, APIMovie>(tableView: tableView) { tableView, indexPath, movie in
            let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.reuseIdentifier) as! MovieTableViewCell
            cell.update(with: movie) {
                self.toggleFavorite(movie)
            }
            return cell
        }
    }
    
    func fetchNewMovies() {
        let searchString = searchController.searchBar.text ?? ""
        if searchString.isEmpty {
            applyNewSnapshot(from: [])
            return
        }
        Task {
            let searchResults = try? await movieController.fetchMovies(with: searchString)
            applyNewSnapshot(from: searchResults ?? [])
        }
    }
    
    func applyNewSnapshot(from movies: [APIMovie]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, APIMovie>()
        snapshot.appendSections([0])
        snapshot.appendItems(movies)
        datasource?.apply(snapshot, animatingDifferences: true)
        tableView.backgroundView = movies.isEmpty ? backgroundView : nil
    }

    func toggleFavorite(_ movie: APIMovie) {
        if let favoriteMovie = movieController.favoriteMovies(from: movie) {
            movieController.unFavoriteMovie(favoriteMovie)
        } else {
            movieController.favoriteMovie(movie)
        }
        reload(movie)
    }
    
    func reload(_ movie: APIMovie) {
        var snapshot = datasource.snapshot()
        snapshot.reloadItems([movie])
        datasource?.apply(snapshot, animatingDifferences: true)
    }
    
}


// MARK: - UISearchResult Updating and UISearchControllerDelegate

extension MovieSearchViewController: UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text, text.isEmpty {
            fetchNewMovies()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        fetchNewMovies()
    }
    
}

extension MovieSearchViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
