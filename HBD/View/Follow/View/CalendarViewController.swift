//
//  CalendarViewController.swift
//  HBD
//
//  Created by 김수경 on 9/1/24.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit

extension CalendarViewController {
    typealias birth = [CalendarBirthDay : [Follow]]
}

final class CalendarViewController: NaivagionBaseViewController {
    
    private let viewModel = CalendarViewModel()
    
    private let calendar = UICalendarView().then {
        $0.isUserInteractionEnabled = true
    }
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .followLayout()).then {
        $0.register(FollowCollectionViewCell.self, forCellWithReuseIdentifier: FollowCollectionViewCell.reuseIdentifier)
    }
    
    private var birthDay = PublishSubject<birth>()
    private let tapCalendar = PublishSubject<DateComponents>()
    
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHierarchy()
        configureLayout()
        configureUI()
        
        bind()
    }
    
    override func navigationBackButtonItemTapped() {
        self.navigationController?.popViewController(animated: false)
    }
        
    private func bind() {
        let load = BehaviorRelay<Void>(value: ())
        let selectDay = PublishSubject<DateComponents>()
        
        let input = CalendarViewModel.Input(load: load, selectDay: selectDay)
        let output = viewModel.transform(input)
        
        tapCalendar
            .subscribe(with: self) { owner, date in
                selectDay.onNext(date)
            }
            .disposed(by: disposeBag)
        
        output.birthdayUser
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(cellIdentifier: FollowCollectionViewCell.reuseIdentifier, cellType: FollowCollectionViewCell.self)) { (item, element, cell) in
                cell.setContents(element.convertToSearchUser())
                cell.setHideButton()
            }
            .disposed(by: disposeBag)
    }
    
    private func setCalendar() {
        calendar.delegate = self
        calendar.selectionBehavior = UICalendarSelectionSingleDate(delegate: self)
    }
    // MARK: - Configure UI
    
    private func configureHierarchy() {
        view.addSubview(calendar)
        view.addSubview(collectionView)
    }
    
    private func configureLayout() {
        let safeArea = view.safeAreaLayoutGuide
        
        calendar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeArea)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(calendar.snp.bottom).offset(10)
            make.horizontalEdges.bottom.equalTo(safeArea)
        }
        
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        setCalendar()
    }
    
}


extension CalendarViewController: UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
       
        if viewModel.followBirthday.contains(where: {
            $0.year == dateComponents.year && $0.month == dateComponents.month && $0.day == dateComponents.day
        }) {
            return .image(UIImage(systemName: "gift.fill"), color: .hbdMain, size: .large)
        }
        
        return nil
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        if let dateComponents {
            tapCalendar.onNext(dateComponents)
        }
    }
    
    
}
