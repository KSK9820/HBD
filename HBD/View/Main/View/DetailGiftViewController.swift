//
//  DetailGiftViewController.swift
//  HBD
//
//  Created by 김수경 on 8/26/24.
//

import UIKit
import WebKit
import SnapKit
import RxCocoa
import RxSwift

final class DetailGiftViewController: NaivagionBaseViewController {
    
    private let viewModel: DetailGiftViewModel
    private let profileView: ContentUserProfileView
    private let informationView: GiftInformationView
    private let webView = WKWebView()
    
    init(content: PostModel) {
        self.viewModel = DetailGiftViewModel(content: content)
        self.profileView = ContentUserProfileView(postUser: viewModel.userInformation)
        self.informationView = GiftInformationView(viewModel: GiftInformationViewModel(content: content))
        
        super.init()
        
        configureHierarchy()
        configureLayout()
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func navigationBackButtonItemTapped() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: false)
        }
    }

    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        view.addSubview(profileView)
        view.addSubview(informationView)
        view.addSubview(webView)
    }
    
    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        profileView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(12)
            make.horizontalEdges.equalToSuperview()
        }
        informationView.snp.makeConstraints { make in
            make.top.equalTo(profileView.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(safeArea).inset(12)
        }
        webView.snp.makeConstraints { make in
            make.top.equalTo(informationView.snp.bottom).offset(12)
            make.horizontalEdges.equalTo(safeArea)
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        if let link = viewModel.link {
            DispatchQueue.main.async { [weak self] in
                self?.webView.load(link)
                self?.webView.snp.makeConstraints { make in
                    make.bottom.equalTo((self?.view.safeAreaLayoutGuide)!)
                }
            }
        }
    }
}
