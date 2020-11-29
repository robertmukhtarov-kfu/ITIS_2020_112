//
//  ImageCell.swift
//  ImageLoadingProject
//
//  Created by Teacher on 16.11.2020.
//

import UIKit

class ImageCell: UITableViewCell {
    var imageUrl: URL? {
        didSet {
            loadImage()
        }
    }

    var title: String? {
        didSet {
            customTitleLabel.text = title
        }
    }

    @IBOutlet private var customTitleLabel: UILabel!
    @IBOutlet private var customImageView: UIImageView!

    private var dataTask: URLSessionDataTask?

    private func loadImage() {
        guard let url = imageUrl else { return }

        dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    self.customImageView.image = image
                }
            }
        }
        dataTask?.resume()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        customImageView?.image = nil
        dataTask?.cancel()
    }
}
