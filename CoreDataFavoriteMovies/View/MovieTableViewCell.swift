//
//  MovieTableViewCell.swift
//  CoreDataFavoriteMovies
//
//  Created by Parker Rushton on 10/31/22.
//

import UIKit
import Kingfisher

class MovieTableViewCell: UITableViewCell {

    static let reuseIdentifier = "MovieTableViewCell"
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var heartButton: UIButton!

    var onFavorite: (() -> Void)?
    
    private var apiMovie: APIMovie?
    private var movie: Movie?
    
    private var heart = UIImage(systemName: "heart")
    private var favoritedHeart = UIImage(systemName: "heart.fill")
    private let placeholderImage = UIImage(named: "moviePlaceholder")
    
    func update(with movie: Movie, onFavorite: (() -> Void)?) {
        self.movie = movie
        self.onFavorite = onFavorite
        posterImageView.kf.setImage(with: movie.posterURL, placeholder: placeholderImage)
        titleLabel.text = movie.title
        yearLabel.text = movie.year
        setFavorite()
    }
    
    
    func update(with movie: APIMovie, onFavorite: (() -> Void)?) {
        self.apiMovie = movie
        self.onFavorite = onFavorite
        posterImageView.kf.setImage(with: movie.posterURL, placeholder: placeholderImage)
        titleLabel.text = movie.title
        yearLabel.text = movie.year
        if MovieController.shared.favoriteMovies(from: movie) != nil {
            setFavorite()
        } else {
            setUnFavorite()
        }
    }

    func setFavorite() {
        heartButton.setImage(favoritedHeart, for: .normal)
        heartButton.tintColor = .red
    }
    
    func setUnFavorite() {
        heartButton.setImage(heart, for: .normal)
        heartButton.tintColor = .gray
    }
    
    @IBAction func favoriteButtonPressed() {
        onFavorite?()
    }
    
}
