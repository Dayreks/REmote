//
//  PhotoLibraryViewController.swift
//  REmote
//
//  Created by Dmytro Hetman on 26.06.2022.
//

import UIKit
import Photos

class PhotoLibraryViewController: UIViewController,  UIScrollViewDelegate{
    
    
    //MARK: - Properties
    
    let columnLayout = ColumnFlowLayout(
        cellsPerRow: 3,
        minimumInteritemSpacing: 3,
        minimumLineSpacing: 3,
        sectionInset: UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
    )
    //MARK: - Outlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        ImageRepository.shared.images = []
//        ImageRepository.shared.currentIndex = 0
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.collectionViewLayout = columnLayout
        self.collectionView.contentInsetAdjustmentBehavior = .always
        
        self.collectionView.isScrollEnabled = true
        self.collectionView.isUserInteractionEnabled = true
        self.collectionView.alwaysBounceVertical = true
        
        ImageRepository.shared.loadMoreImages(limit: 100)
        
        self.updateImages()
        
        
        ImageRepository.shared.imagesLoadedHandler = {
            self.reloadDataAsync()
        }
        
        self.collectionView.scrollsToTop = true
        
    }

    
    
    func updateImages() {
        switch ImageRepository.shared.emotionForCurrentLoad {
        case "angry":
            ImageRepository.shared.images.append(contentsOf: EmotionsData.shared.angry)
        case "happy":
            ImageRepository.shared.images.append(contentsOf: EmotionsData.shared.happy)
        case "sad":
            ImageRepository.shared.images.append(contentsOf: EmotionsData.shared.sad)
        case"disgust":
            ImageRepository.shared.images.append(contentsOf: EmotionsData.shared.disgust)
        case "fear":
            ImageRepository.shared.images.append(contentsOf: EmotionsData.shared.fear)
        case "neutral" :
            ImageRepository.shared.images.append(contentsOf: EmotionsData.shared.neutral)
        case "surprise" :
            ImageRepository.shared.images.append(contentsOf: EmotionsData.shared.surprise)
        default:
            print("No matching emotion")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        DispatchQueue.main.async {
//            self.collectionView.scrollToBottom(animated: false)
//        }
        
    }
    
    private func reloadDataAsync() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let postion = scrollView.contentOffset.y
        if postion > (collectionView.contentSize.height - scrollView.frame.size.height - 100){
            print("loading data")
            ImageRepository.shared.images = []
            ImageRepository.shared.loadMoreImages(limit: 50)
            self.updateImages()
            collectionView.reloadData()
        }
    }
    
    
}

extension UICollectionView {
    
    // MARK: - UICollectionView scrolling/datasource
    /// Last Section of the CollectionView
    var lastSection: Int {
        return numberOfSections - 1
    }
    
    /// IndexPath of the last item in last section.
    var lastIndexPath: IndexPath? {
        guard lastSection >= 0 else {
            return nil
        }
        
        let lastItem = numberOfItems(inSection: lastSection) - 1
        guard lastItem >= 0 else {
            return nil
        }
        
        return IndexPath(item: lastItem, section: lastSection)
    }
    
    /// Islands: Scroll to bottom of the CollectionView
    /// by scrolling to the last item in CollectionView
    func scrollToBottom(animated: Bool) {
        guard let lastIndexPath = lastIndexPath else {
            return
        }
        scrollToItem(at: lastIndexPath, at: .bottom, animated: animated)
    }
    
    
    
}

extension PhotoLibraryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ImageRepository.shared.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.cellReuseID, for: indexPath) as! PhotoCollectionViewCell
        
        cell.config(image: ImageRepository.shared.images[indexPath.row])
        
        return cell
    }
    
}
