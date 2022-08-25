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
    
}

enum Notification {
    static let goToHoner = "goToHoner"
    static let showPopUpSixtySixth = "PopUpSixtySixth"
}

