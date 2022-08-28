//
//  constants.swift
//  Habits
//
//  Created by 안지훈 on 8/3/22.
//

import Foundation
import UIKit

enum Segue {
    static let goToAddView = "goToAddView"
    static let goToCollectionView = "goToCollectionView"
    static let goToCheckVC = "goToCheckVC"
}

enum Cell {
    static let customTableViewCell = "customTableViewCell"
    static let HabitsCustomCollectionViewCell = "HabitsCustomCollectionViewCell"
    static let nibName = "HabitCell"
    static let pausedHabitCell = "PausedHabitCell"
    static let pausedNibName = "PausedHabitTableViewCell"
}

enum ImageName {
    static let bookmarkImage = "bookmarkImage"
    static let ic_pause = "ic-pause"
    static let swipeBookmark = "swipeBookmark"
    static let dongri = "Dongri"
    static let deleteButton = "deleteButton"
}

enum Notification {
    static let goToHoner = "goToHoner"
    static let showPopUpSixtySixth = "PopUpSixtySixth"
}

enum Color {
    static let backgroundColor = "ViewBackground"
}

enum RealmQuery {
    static let notInHOF = "isInHOF = false"
    static let InHOF = "isInHOF = true"
    
    static let notPausedHabit = "isPausedHabit = false"
    static let pausedHabit = "isPausedHabit = true"
    
    static let habitID = "habitID = %@"
    
}

enum CustomFont {
    static let hyemin = "IM_Hyemin"
    static let hyemin_Bold = "IMHyemin-Bold"
}

enum KeyText {
    static let isBookmarked = "isBookmarked"
    
    static let alertTitleKey = "attributedTitle"
    static let alertSubTitleKey = "attributedMessage"
    
    static let titleTextColor = "titleTextColor"
}

enum ListHomeLabel {
    static let listHomeEmptyLabel = "하고 있는 습관이 아직 없어요 🥲\n습관을 만들어볼까요?"
    static let wantToPauseLabel = "✋습관을 잠깐 멈추시겠어요?"
    static let wantToPauseSubLabel = "\n멈춘 습관은 '잠시 멈춤'에 보관되며\n언제든지 다시 시작하실 수 있습니다.\n다만, 다시 시작하실 때는 1일차로 돌아갑니다.😢"
    static let alertActionKeepChallenge = "계속 도전"
    static let alertActionPauseHabit = "멈추기"
}

enum PausedHabitLabel {
    static let restartLabel = "🏃\n습관을 다시 시작할까요?"
    static let restartSubLabel = "1일차부터 차근차근 힘내봐요!"
    
    static let alertActionRestart = "다시 시작"
    static let alertActionCancel = "취소"
    static let alertActionDelete = "삭제"
    
    static let wantToDelete = "습관을 삭제할까요?"
    static let nonePausedHabit = "멈춰있는 습관이 없어요!"
}

enum HOFLabel {
    static let hOFEmptyLabel = "66일 간의 여정을 완료해서\n습관의 전당을 채워보세요!"
}

enum ToastMessage {
    static let addLimitToast = "최대 추가 개수는 20개 입니다."
    static let goodChoiceToast = "잘 선택 하셨어요! 끝까지 화이팅! 👍"
    static let pauseCompleteToast = "다시 시작하실 그 날을 기약하며 \n습관이 ‘잠시 멈춤’에 보관되었습니다. 👋"
    static let emptyTitleToast = "습관을 입력해주세요!"
    static let alreadyExistHabitToast = "이미 있는 습관입니다!"
    static let textLimitToast = "15자 내로 작성해주세요."
    static let habitDeleteCompleteToast = "습관이 삭제되었습니다."
}
