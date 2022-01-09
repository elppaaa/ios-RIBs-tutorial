//
//  LaunchGameWorkflow.swift
//  TicTacToe
//
//  Created by JK on 2022/01/10.
//  Copyright © 2022 Uber. All rights reserved.
//

import Foundation
import RIBs
import RxSwift


/// 각 동작 흐름을 `ActionableItem` 프로토콜을 채택한 `Interactor` 를 순회하며 동작함
/// Observable `flatMap` 과 유사한 느낌....
public class LaunchGameWorkflow: Workflow<RootActionableItem> {
  public init(url: URL) {
    super.init()
    
    let gameID = parseGameID(from: url)
    
    /// Workflow 의 동작 순서를 정의한다고 보면 된다.
    /// 각 동작은 `ActionableItem` 프로토콜 단위이고, 해당 프로토콜을 `Interactor` 가 채택해 기능을 구현한다.
    self
    /// `RootActionableItem` 을 채택하고 있는 `RootInteractor` 에서 `waitForLogin()` 을 호출한다..
      .onStep { (rootItem: RootActionableItem) -> Observable<(LoggedInActionableItem, ())> in
        rootItem.waitForLogin()
      }
      .onStep { (loggedInItem: LoggedInActionableItem, _) -> Observable<(LoggedInActionableItem, ())> in
        loggedInItem.launchGame(widh: gameID)
      }
      .commit()
  }
  
  private func parseGameID(from url: URL) -> String? {
    let components = URLComponents(string: url.absoluteString)
    let items = components?.queryItems ?? []
    for item in items {
      if item.name == "gameId" {
        return item.value
      }
    }
    
    return nil
  }
  
}
