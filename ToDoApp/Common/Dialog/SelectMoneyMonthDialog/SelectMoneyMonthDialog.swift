//
//  MoneyInformationDialogViewController.swift
//  MoneyManager
//
//  Created by Mei Mei on 28/07/2023.
//

import UIKit
import RxSwift

class SelectMoneyMonthDialog: UIViewController {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var list = [ListMoneyWithMonthViewModel]()
    var currentIndex: Int = 0
    var didSelectMonth: AnyObserver<Int>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        config()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if !self.mainView.bounds.contains(touches.first!.location(in: self.mainView)) {
            self.dismiss()
        }
    }

    func dismiss() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    private func config() {
        configCollectionView()
    }
    
    private func configCollectionView() {
        collectionView.registerCell(type: SelectMoneyMonthCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 0, left: 15, bottom: 0, right: 15)
    }

    @IBAction func cancelButtonDidTap(_ sender: Any) {
        self.dismiss()
    }
}

// MARK: - CollectionVie
extension SelectMoneyMonthDialog: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return list.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueCell(type: SelectMoneyMonthCell.self, indexPath: indexPath) else {
            return UICollectionViewCell()
        }
        
        let data = list[indexPath.row]
        cell.bindData(viewModel: data)
        cell.updateSelectedState(isSelected: indexPath.row == currentIndex)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectMonth?.onNext(indexPath.row)
        self.dismiss()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 30, height: 40)
    }
}
