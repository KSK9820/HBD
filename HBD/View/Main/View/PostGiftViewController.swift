//
//  PostGiftViewController.swift
//  HBD
//
//  Created by 김수경 on 8/28/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import PhotosUI
import Toast

final class PostGiftViewController: UIViewController {
    
    private let viewModel: PostGiftViewModel
    
    private let popupView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 10
    }
    private let titleTextField = UITextField().then {
        $0.placeholder = "제목"
        $0.backgroundColor = .hbdPink.withAlphaComponent(0.3)
        $0.layer.cornerRadius = 8
        $0.addLeftPadding(16)
    }
    private let priceTextField = UITextField().then {
        $0.placeholder = "가격"
        $0.backgroundColor = .hbdPink.withAlphaComponent(0.3)
        $0.layer.cornerRadius = 8
        $0.addLeftPadding(16)
    }
    private lazy var recruitmentTextField = UITextField().then {
        $0.placeholder = "모집 인원"
        $0.backgroundColor = .hbdPink.withAlphaComponent(0.3)
        $0.layer.cornerRadius = 8
        $0.addLeftPadding(16)
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        $0.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(recruitDonePressed))
        toolbar.setItems([doneButton], animated: true)
        
        $0.inputAccessoryView = toolbar
    }
    private lazy var deadLineTextField = UITextField().then {
        $0.placeholder = "마감 날짜"
        $0.backgroundColor = .hbdPink.withAlphaComponent(0.3)
        $0.layer.cornerRadius = 8
        $0.addLeftPadding(16)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        $0.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(deadLineDonePressed))
        toolbar.setItems([doneButton], animated: true)
        
        $0.inputAccessoryView = toolbar
    }
    private let linkTextField = UITextField().then {
        $0.placeholder = "사이트 링크"
        $0.backgroundColor = .hbdPink.withAlphaComponent(0.3)
        $0.layer.cornerRadius = 8
        $0.addLeftPadding(16)
    }
    private let contentTextView = UITextView().then {
        $0.text = "내용"
        $0.backgroundColor = .hbdPink.withAlphaComponent(0.3)
        $0.layer.cornerRadius = 8
        $0.textColor = .gray
        $0.font = .systemFont(ofSize: 14)
        $0.addLeftPadding(16)
    }
    private let imageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 8
        $0.image = UIImage(systemName: "photo")?.withTintColor(.hbdPink.withAlphaComponent(0.3)).withRenderingMode(.alwaysOriginal)
        $0.contentMode = .scaleAspectFit
        $0.layer.borderWidth = 2
        $0.layer.borderColor = UIColor.hbdPink.withAlphaComponent(0.3).cgColor
        $0.isUserInteractionEnabled = true
    }
    
    private let postButton = UIButton().then {
        $0.setTitle("선물 하자!", for: .normal)
        $0.backgroundColor = .hbdMain
        $0.setTitleColor(.white, for: .normal)
        $0.layer.cornerRadius = 8
    }
    
    private let disposeBag = DisposeBag()
    
    init(id: String) {
        self.viewModel = PostGiftViewModel(followingID: id)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureLayout()
        configureUI()
        
        bind()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
          if let touch = touches.first {
              let location = touch.location(in: view)
              let popupView = view.subviews.first { $0 != self.view }
              if let popupView = popupView, !popupView.frame.contains(location) {
                  dismiss(animated: true, completion: nil)
              }
          }
      }
    
    private func bind() {
        let imageData = PublishSubject<[Data]>()
        let postData = PublishSubject<UploadPostQuery>()
        
        let textFieldFilled = Observable.combineLatest(
            titleTextField.rx.text.orEmpty,
            priceTextField.rx.text.orEmpty,
            recruitmentTextField.rx.text.orEmpty,
            deadLineTextField.rx.text.orEmpty,
            linkTextField.rx.text.orEmpty
        ) { text1, text2, text3, text4, text5 in
            return !text1.isEmpty && !text2.isEmpty && !text3.isEmpty && !text4.isEmpty && !text5.isEmpty
        }
        
        let input = PostGiftViewModel.Input(imageData: imageData, postModelData: postData)
        let output = viewModel.transform(input)
        
        postButton.rx.tap
            .withLatestFrom(textFieldFilled)
            .map { [weak self] _ in

                guard let self else { return false }
                
                if self.imageView.image == UIImage(systemName: "photo")?.withTintColor(.hbdPink.withAlphaComponent(0.3)).withRenderingMode(.alwaysOriginal) { return false }

                return true
            }
            .subscribe(with: self) { owner, isValid in
                if isValid {
                    guard let image = owner.imageView.image,
                          let jpegData = image.jpegData(compressionQuality: 0.5)
                    else { return }
                    
                    imageData.onNext([jpegData])
                } else {
                    owner.view.makeToast("모든 정보를 알려주세요.")
                }
            }
            .disposed(by: disposeBag)
        
        output.stringImageData
            .subscribe(with: self) { owner, stringImage in
                let giftData = UploadPostQuery(
                    title: owner.titleTextField.text!,
                    price: Int(ceil(Double(owner.priceTextField.text!)!/Double(owner.recruitmentTextField.text!)!)),
                    content: owner.contentTextView.text!,
                    content1: owner.linkTextField.text!,
                    content2: owner.recruitmentTextField.text!,
                    content3: owner.deadLineTextField.text!,
                    content4: owner.priceTextField.text!,
                    productID: owner.viewModel.followingID,
                    files: stringImage
                )
                postData.onNext(giftData)
            }
            .disposed(by: disposeBag)
        
        output.postResult
            .asDriver(onErrorJustReturn: false)
            .drive(with: self) { owner, result in
                switch result {
                case true:
                    if let presentingVC = owner.presentingViewController {
                        presentingVC.view.makeToast("🎁선물이 등록되었습니다🎁", duration: 1.0)
                    }
                    owner.dismiss(animated: false)
                case false:
                    owner.view.makeToast("선물 등록에 실패하였습니다.")
                }
                
            }
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        view.addSubview(popupView)
        [titleTextField, priceTextField, imageView ,recruitmentTextField, deadLineTextField, linkTextField, contentTextView, postButton].forEach {
            popupView.addSubview($0)
        }
    }
    
    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        popupView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(ContentSize.profileImageCell.size.height + 10)
            make.horizontalEdges.equalTo(safeArea).inset(20)
            make.bottom.equalTo(safeArea).offset(-10)
        }
        
        titleTextField.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(popupView).inset(12)
            make.height.equalTo(ContentSize.unit.size.width)
        }
        
        priceTextField.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(popupView).inset(12)
            make.height.equalTo(ContentSize.unit.size.width)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(priceTextField.snp.bottom).offset(16)
            make.leading.equalTo(popupView).offset(12)
            make.size.equalTo(ContentSize.unit.size.width * 2 + 16)
        }
        
        recruitmentTextField.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top)
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalTo(popupView).offset(-12)
            make.height.equalTo(ContentSize.unit.size.width)
        }
        
        deadLineTextField.snp.makeConstraints { make in
            make.top.equalTo(recruitmentTextField.snp.bottom).offset(16)
            make.leading.equalTo(imageView.snp.trailing).offset(12)
            make.trailing.equalTo(popupView).offset(-12)
            make.height.equalTo(ContentSize.unit.size.width)
        }
        
        linkTextField.snp.makeConstraints { make in
            make.top.equalTo(deadLineTextField.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(popupView).inset(12)
            make.height.equalTo(ContentSize.unit.size.width)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(linkTextField.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(popupView).inset(12)
        }
        
        postButton.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(16)
            make.horizontalEdges.equalTo(popupView).inset(12)
            make.bottom.equalTo(popupView).offset(-16)
            make.height.equalTo(ContentSize.unit.size.width)
            
        }
    }
    
    private func configureUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addGesture()
    }
    
    private func addGesture() {
        let imageTapGesture = UITapGestureRecognizer()
        imageView.addGestureRecognizer(imageTapGesture)
        
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self

        imageTapGesture.rx.event
            .bind(with: self, onNext: { owner, _ in
                owner.present(picker, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    @objc func dismissPopup() {
        dismiss(animated: false, completion: nil)
    }
    
    @objc func recruitDonePressed() {
        recruitmentTextField.resignFirstResponder()
    }
    
    @objc func deadLineDonePressed() {
        deadLineTextField.resignFirstResponder()
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        deadLineTextField.text = dateFormatter.string(from: sender.date)
    }
    
}

extension PostGiftViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        viewModel.recruitmentNum.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        viewModel.recruitmentNum[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        recruitmentTextField.text = viewModel.recruitmentNum[row]
    }
}

extension PostGiftViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if let itemProvider = results.first?.itemProvider {
            itemProvider.canLoadObject(ofClass: UIImage.self)
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.image = image as? UIImage
                }
            }
        }
    }
}
