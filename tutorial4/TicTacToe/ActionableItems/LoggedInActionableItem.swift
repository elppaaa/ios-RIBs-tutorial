//
//  LoggedInActionableItem.swift
//  TicTacToe
//
//  Created by JK on 2022/01/10.
//  Copyright © 2022 Uber. All rights reserved.
//

import Foundation
import RxSwift

public protocol LoggedInActionableItem: AnyObject {
  func launchGame(widh id: String?) -> Observable<(LoggedInActionableItem, ())>
}
