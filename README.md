# Atomic Haibit 

 ### 습관 기록 어플리케이션 
- 효과적인 습관을 만드는데 필요한 기간은 `최소 66일`이다.
- 영국 런던대 임상심리학고 `제인 위들 교수`는 평균적으로 습관을 만드는 `66일`이 걸린다고 합니다. 
- 어플리케이션을 통해서 핵심습관을 만들고 더 나은 하루를 살아보는것이 어떨까요 

</br>

----

# 동작
![hallofFrame](https://user-images.githubusercontent.com/51688166/182628562-d1f520b4-9b16-4d56-b2a7-384587f0f86a.gif)
![habitresist](https://user-images.githubusercontent.com/51688166/182623152-0903af32-c5e8-4b93-88d0-683ffa964cc7.gif)


![recilickrestrict](https://user-images.githubusercontent.com/51688166/182623081-65a2761b-2ea3-4fb8-94d2-8fc444810d8c.gif)
![bookmark](https://user-images.githubusercontent.com/51688166/182623088-98289ec3-0131-4811-9d69-ae01eb1cd30d.gif)



----

</br>

# 주요기능 

1. 습관을 `등록` 할 수 있다. ( 최대 20개 ) 
2. 66일을 완료하게되면 `명예의 전당`에 등록된다. 
3. 습관 리스트에서 `즐겨찾기` 기능 
4. 습관의 `진행사항을 확인` 할 수 있다. ( 몇일동안 했는지 ) 

</br>

----

</br>


# 사용기술 


###  DataBase 
- `Realm`

### Library
- `Toast` 

### `UIKit`
- `UITableView` 
- `UICollectionView`
- `UIAlert` 


### Event 
`Delegate` , `segue`

### AutoLayout
- `StoryBoard` & `Code`

### UI 
- `Main.storyboard` & `.xib`

</br>

----

</br>

----

</br>

# 역할 

### 공통 

- 기본적인 UI 설정 
- Realm데이터 생성 및 추가

### AhnZ

- Calender를 이용한 시간데이터 처리 
- Realm데이터 처리
- 버튼 이미지 변환 ( Code ) 

1. 현재시간과 Realm데이터에 저장된 시간을 비교 
2. Realm데이터 습관완료 숫자를 받아와서 그에 따른 UIbutton 설정
3. Realm 데이터 Title의 길이에 따른 CheckVC타이틀 크기조정 

- Toast 
1. 하루에 한번 이상 클릭 시 제한 ( Toast )
2. ToastStyle 지정 

AutoLayout 
1. 66개의 button 생성 및 각각 오토레이아웃 ( Code ) 
2. StoryBoard Constraint에 맞춘 TitleLabel의 Font크기 조절 


### Hoonsbrand

- Realm 데이터 처리 ( 즐겨찾기, 추가, 명예의전당 )
- texFildDelegate 
- CollectionViewCell 색 처리 ( Code ) 

- UI
1. Custom Cell 
2. Composible CollectionView 

- Event ( Protocol Delegate ) 
1. 즐겨찾기 이벤트 처리
2. 66일 달성 시 명예의 전당 추가 ) 

- Toast 
1. 습관 등록시 글자수 15제한 ( 넘으면 토스트 팝업 ) 
2. 빈제목으로 등록 불가 
3. 최대습관 20개 제한

- AutoLayout 
1. StoryBoard ( CustomCell, AddView ) 
2. Code ( CollectionViewCell, TableViewCell )





- 커스텀 셀을 이용한 UI 디자인
- 프로토콜을 이용한 즐겨찾기 버튼 클릭시 이벤트
- 컴포지셔널 레이아웃을 이용한 커스텀 컬렉션 뷰로 명예의 전당 구현
- 66일이 되었을 시 리스트에서 숨김 & 명예의 전당으로 이동
- 습관 등록시 글자수 15자 제한 & Toast 팝업
- 습관 등록시 빈 제목으로 등록 불가 & Toast 팝업
- 최대 습관 등록 20개 제한 & Toast 팝업

# 문제점

- 습관의 진행사항 : 하루가 지나야 클릭 할 수 있지만. 2일이나 3일이 지나도  바로 다음날의 습관처럼 기록이 된다.
>ex) 하루 습관을 기록하고 2일이 지났을때 
 o x x x x -> o x x o x x   이렇게 되는게 아니라 
 o x x x x -> o o x x x x 이런식으로 기록된다. 
- 동일한 습관을 등록 할 때, 등록한 습관이 명예의 전당에 있다면 데이터가 충돌된다. 
- 삭제 기능 ( 테이블뷰 CheckVC 중에 고민 ) 
- 디자인 ( 기본 기능만 작동함 ) = 깔끔한 UI가 아님



