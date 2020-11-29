//
//  ScrollViewController.swift
//  ImageLoadingProject
//
//  Created by Robert Mukhtarov on 28.11.2020.
//

import UIKit

class ScrollViewController: UIViewController, URLSessionDownloadDelegate, UIScrollViewDelegate {
    
    var imageUrl: URL?
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        progressView.setProgress(0, animated: false)
        loadImage()
    }
    
    // MARK: - File Download
    
    private func loadImage() {
        guard let url = imageUrl else { return }
        let operationQueue = OperationQueue()
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: operationQueue)
        let downloadTask = session.downloadTask(with: url)
        downloadTask.resume()
        session.finishTasksAndInvalidate()
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        DispatchQueue.main.async {
            if totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown {
                self.progressView.isHidden = true
                return
            }
            let calculatedProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            self.progressView.setProgress(calculatedProgress, animated: true)
        }
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        let data = try? Data(contentsOf: location)
        DispatchQueue.main.async {
            guard let data = data else {
                self.showAlert(message: "Can't read the downloaded file")
                return
            }
            guard let image = UIImage(data: data) else {
                self.showAlert(message: "The downloaded file is not an image")
                return
            }
            self.setupScrollView(with: image)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            showAlert(message: error.localizedDescription)
        }
    }
        
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Download failed", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
    
    // MARK: - Scroll View
    
    private func setupScrollView(with image: UIImage) {
        imageView.image = image
        progressView.isHidden = true
        scrollView.isHidden = false
        setZoomScale(for: image.size)
    }
    
    private func setZoomScale(for size: CGSize) {
        let widthScale = scrollView.bounds.width / size.width
        let heightScale = scrollView.bounds.height / size.height
        let scale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = scale
        scrollView.zoomScale = scale
        scrollView.maximumZoomScale = scale * 10
        
        let imageWidth = size.width * scale
        let imageHeight = size.height * scale
        let imageFrame = CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight)
        imageView.frame = imageFrame
        
        centerImage()
    }
    
    private func centerImage() {
        let contentViewSize = scrollView.frame.size
        imageView.frame.origin.x = imageView.frame.size.width < contentViewSize.width ? (contentViewSize.width - imageView.frame.size.width) / 2 : 0
        imageView.frame.origin.y = imageView.frame.size.height < contentViewSize.height ? (contentViewSize.height - imageView.frame.size.height) / 2 : 0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}
