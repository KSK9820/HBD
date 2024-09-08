//
//  MyInformationViewController.swift
//  HBD
//
//  Created by 김수경 on 9/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class MyInformationViewController: UIViewController {
    
    private let segmentedControl = UISegmentedControl(items: ["myGiftView", "myPaymentView"]).then {
        $0.setTitle("내 선물 목록", forSegmentAt: 0)
        $0.setTitle("내 결제 목록", forSegmentAt: 1)
        $0.backgroundColor = .hbdPink
        $0.addTarget(self, action: #selector(segmentedControlTapped(sender:)), for: .valueChanged)
    }
    private let myGiftView = MyGiftView()
    private let myPaymentView = MyPaymentView()
    
    private var shouldHideFirstView: Bool? {
        didSet {
            guard let shouldHideFirstView = self.shouldHideFirstView else { return }
            self.myGiftView.isHidden = shouldHideFirstView
            self.myPaymentView.isHidden = !self.myGiftView.isHidden
        }
    }
 
    override func viewDidLoad() {
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    
    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        view.addSubview(segmentedControl)
        [myGiftView, myPaymentView].forEach {
            view.addSubview($0)
        }
    }
    
    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(10)
            make.centerX.equalTo(safeArea)
        }
        myGiftView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(safeArea)
        }
        myPaymentView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(safeArea)
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        configureSegmentedControl()
        configureNavigation()
    }
    
    private func configureSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 1
        segmentedControlTapped(sender: segmentedControl)
    }
    
    private func configureNavigation() {
        navigationItem.title = "마이 페이지"
    }
    
    @objc private func segmentedControlTapped(sender: UISegmentedControl) {
        self.shouldHideFirstView = sender.selectedSegmentIndex != 0
    }
}
