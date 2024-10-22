

# 해비디

> 함께하는 순간, 선물이 더 특별해집니다.
> <br/> 친구들과 함께 더 큰 선물을 선물할 수 있는 앱

![image](https://github.com/user-attachments/assets/5746958e-6f51-4561-bf5d-9448d39fe94f)

## 프로젝트 환경

- 인원: iOS 개발자 1명, backend 개발자 1명
- 기간: 2024년 8월 19일 - 9월 8일
- 최소 버전: iOS 17 +
- 기술 스택
    - **Framework**: UIKit
    - **Reactive Programming**: RxSwift, RxDataSource
    - **Architecture**: MVVM
    - **네트워크**: Alamofire
    - **결제**: iamPort-iOS
 
## 주요 기능

- **`팔로우 검색 화면`**: 유저 검색과 현재 팔로우 하고 있는 유저를 follow, unfollow 관리할 수 있는 화면
    - 아무것도 검색하지 않을 경우에는 팔로우하고 있는 유저의 목록을 확인할 수 있습니다.
    - 유저의 이름으로 검색을 할 수 있습니다.
- **`캘린더 화면`** : 팔로우하고 있는 유저의 생일과 정보를 캘린더에서 확인할 수 있는 화면
    - 팔로우 하고 있는 유저의 생일은 캘린더에 🎁(빨간 선물 박스)로 표시되며 선택시 캘린더의 하단에서 유저의 정보를 확인할 수 있습니다.
- **`메인 화면`** : 팔로우 유저들의 선물 목록 조회 및 포스트 화면
    - 상단에 팔로우 하고 있는 유저를 가로 스크롤을 통해서 확인할 수 있습니다.
    - 유저를 선택하면 유저에게 등록된 선물, 가격, 참가 인원 등을 새로 스크롤을 통해 조회할 수 있습니다.
    - 1인당 참여 금액 버튼을 선택하면 결제를 할 수 있고, 참가한 선물은 재참가할 수 없습니다.
    - 선물을 선택하면 선물의 상세 정보를 웹뷰를 통해 확인할 수 있습니다.
    - 선물 목록인 새로 스크롤은 페이지네이션 기능을 구현하였습니다.
- **`선물 등록 화면`** : 친구의 선물을 등록할 수 있는 화면
    - 가로 스크롤에서 친구를 선택한 후에 floating button을 선택하면 해당 친구의 선물을 등록할 수 있습니다.
    - PHPickerViewControllerDelegate를 사용해서 thumbnail 이미지를 등록할 수 있습니다.
- **`결제 화면`** : 친구에게 줄 선물을 결제하는 화면
    - PG 결제를 구현했습니다.
- **`마이 페이지 화면`** : 내가 친구에게 선물한 선물의 목록과 내 선물들을 조회할 수 있는 화면
    - 내 결제 목록: 나(😎) → 친구(😀) 에게 결제한 선물의 목록을 조회할 수 있습니다.
    - 내 선물 목록: 친구(😀) → 나(😎) 에게 등록한 선물의 목록을 조회할 수 있습니다.
 
### 화면
- 메인 화면


|메인 선물 조회|참가 완료 선물|선물 상세 보기|
|:--:|:--:|:--:|
|![메인화면1](https://github.com/user-attachments/assets/58a2b21c-ab30-4bbf-bf58-668a7686831e)|![메인화면2](https://github.com/user-attachments/assets/edeabbf9-e2cb-4210-81f5-099546390432)|![상세화면1](https://github.com/user-attachments/assets/d0acacd7-05d2-4e3f-9938-cb6f6588f1ff)|


- 검색 및 캘린더 화면

|팔로우 유저 조회|유저 검색|캘린더 조회|
|:--:|:--:|:--:|
|![팔로우1](https://github.com/user-attachments/assets/0fa06d5f-7768-4a02-9063-1a859e0042e9)|![팔로우3](https://github.com/user-attachments/assets/c6826d96-6e75-41e6-94ec-7011d1759379)|![팔로우4](https://github.com/user-attachments/assets/cb44f7aa-b15b-48d9-a90c-118a6a486da3)|

- 등록 화면 및 마이페이지


|선물 결제|내가 결제한 목록|내 선물 목록|
|:--:|:--:|:--:|
|![결제](https://github.com/user-attachments/assets/a5e009cd-88a2-41e0-8fad-ff50e9e2de00)|![내결제1](https://github.com/user-attachments/assets/995944ab-46d8-4934-8387-c84a92dd975f)|![내선물1](https://github.com/user-attachments/assets/ddb5ebd7-2f55-4560-a655-8a47f8e35fa6)|||

- 기기 사이즈 대응

|iPhone 15 Max|iPhone 15|iPhone SE3|
|:--:|:--:|:--:|
|![image](https://github.com/user-attachments/assets/5d36800f-bb15-4b94-bf66-b22e2c8ec310)|![image](https://github.com/user-attachments/assets/987f90e0-b223-48a1-afb8-a2d3237635bc)|![image](https://github.com/user-attachments/assets/1b67ef2d-897f-4e91-b3f1-de11002196ca)|



<br/>

## 기술 스택 상세

- **Router Pattern과 Custom HTTPRequestable 프로토콜 활용**
    - 네트워크 설계시에 Router Pattern을 사용한 이유로는
        - 네트워크 요청을 추상화하여 코드 가독성과 유지보수성을 향상시켰습니다.
        - API 엔드포인트를 Router로 관리하여, 여러 개의 API 주소를 하나의 구조체에서 효율적으로 관리할 수 있었습니다.
    - Custom HTTPRequestable 프로토콜을 사용한 이유로는
        - `동적인 경로`, `버전`, `쿼리 파라미터`, `포트 번호` 등을 제어할 수 있어 복잡한 서버 환경에서도 유연하게 대응하기 위해서 Custom HTTPRequestable을 직접 구현하여서 사용하였습니다.
- **RxSwift + MVVM 아키텍처**
    - 반응형 프로그래밍인 RxSwift를 사용한 이유로는
        - 이벤트 기반 흐름에서 데이터 변화를 즉각적으로 감지하고 UI를 업데이트할 수 있어, UI와 데이터간의 동기화에 용이합니다. 또한 RxCocoa를 통해 사용자 이벤트를 처리할 수 있어서 UI와 로직의 결합을 효율적으로 처리할 수 있기 때문에 RxSwift를 사용하였습니다.
        - 또한 하나의 CollectionView에서 여러 개의 Section과 각각 다른 Layout을 사용하기 위해 `RxDataSource`를 사용하였습니다.
    - MVVM을 사용한 이유로는
        - 비즈니스 로직과 UI 로직을 분리하여, 동일한 ViewModel을 여러 View에서 `재사용`하여 코드의 중복을 줄이고, 유지보수성을 향상시킬 수 있습니다.
        - RxCocoa와 Input/Output 패턴을 사용하여 Input을 ViewModel에게 전달할 때 단방향으로 데이터의 흐름을 유지하기 때문에 코드 구조를 단순화할 수 있었습니다. 
        - **별도의 객체로 iamPort-iOS를 사용한 PG 결제 및 유효성 검증**
            - iamPort-iOS 문서에서 View 내에서 PG 결제를 처리하지 않고, `PaymentManger` 별도의 객체로 PG 결제 로직을 관리하면 결제와 관련된 로직을 중앙 집중화할 수 있어 유지보수가 쉬워집니다.
            - `PaymentManager` 내에서 결제 데이터 검증을 추가하여, 잘못된 데이터로 결제가 진행되지 않도록 방지할 수 있습니다.
- **서버의 통신 모델(DTO)과 앱 내 데이터 모델(Model) 분리**
    - 서버의 DTO와 앱 내에서 사용하는 Model을 분리함으로써, 서버의 데이터 구조가 변경되더라도 `앱 내 Model은 그대로 유지`할 수 있고, 앱 내부의 비즈니스 로직이나 UI 로직이 불필요하게 변경되는 것을 방지할 수 있습니다.
- **Compositional Layout 및 기기 화면 사이즈의 비율에 맞춘 다양한 기기 화면에 대응하는 레이아웃 구현**
    - 기기의 가로, 세로 크기를 기반으로 각 컴포넌트의 CGSize를 비율로 계산해서 컴포넌트의 크기를 사용하기 때문에 다양한 기기에 맞는 화면을 구현할 수 있습니다.

<br/>

# 트러블 슈팅
## TroubleShooting1

- 데이터를 CollectionView에 표시하고자 할 때 `CollectionView`를 찾지 못 하는 문제가 있었다.
    
![image](https://github.com/user-attachments/assets/3c8fbbbe-873d-45a6-a185-452bbf814a22)
    
![image](https://github.com/user-attachments/assets/32e4c3ff-8659-4093-9890-61a373afef76)
    
  - 디버그로는 subscribe 내부에서 owner(= self)를 확인할 때에도 searchVeiwController가 있음이 확인되었고
    
![image](https://github.com/user-attachments/assets/006ce6f6-2306-4298-a344-4b81940bd762)
    
- CollectionView 또한 마찬가지로 찾을 수 있었지만
- 프로그램 빌드도 전에 CollectionView 자체를 인식하지 못 하는 컴파일 에러가 발생하였다.

### TroubleShooting1 해결
    
```swift
    .drive(with: self, onNext: { owner, value in
        self.searchFollowCollectionView.rx.items(...)
    })
    // 는 동작하지 않지만 
```
    
```swift
    .drive(searchFollowCollectionView.rx.items(...))
    // 는 동작한다.
```

![image](https://github.com/user-attachments/assets/01c6f5dc-1e17-4237-9837-f08ae9fd4a75)
    
  - items는 Source로 ObservableType을 필요로 하는데,
        → drive는 Observable 시퀸스의 각 이벤트를 자동으로 collectionview의 datasource로 사용하지만
        → drive(with)는 전달하는 value값이 items의 Source에서 사용되지 못 하고 있기 때문에 발생한 문제였다.
        - drive 뿐 아니라 bind에서도 동일하게 동작하고 있다.

## TroubleShooting2

- cell의 재사용 문제
    - 사용자를 검색할 때마다 CollectionView를 다시 그리는데, 첫 검색은 Button이 잘 동작하지만 두 번째 검색 부터는 Button.rx.tap을 인식하지 못 하는 문제가 있었다.
    - 첫 번째 검색은 동작하지만 두 번째 부터는 동작하지 않는 것으로 보아 cell의 재사용이 원인임을 알게 되었다.
- 기존에는 bind()를 init에서 호출하였는데 → cell은 재사용되기 때문에 재사용 되는 cell이 매번 init 되지 않는다
     <img src="https://github.com/user-attachments/assets/dfd19073-9718-4c86-ac8c-6e2d1d11ddae" width="200">
    
    - cell의 data 개수와 init 호출 횟수가 동일하지 않다.
### TroubleShooting2 해결
- init시에 bind를 호출하지 않고, cell을 재사용하되 내용을 채우는 setContents내부에서 bind메서드를 호출하도록 변경함으로 cell의 재사용과 연관된 버튼 동작의 오류를 해결하였다.
    
    ![image](https://github.com/user-attachments/assets/072c4133-de44-4783-8a57-4cbfc0774d80)
    
   ![image](https://github.com/user-attachments/assets/f2f9e254-9343-4c6e-99bb-5d5ee0f67cbc)
