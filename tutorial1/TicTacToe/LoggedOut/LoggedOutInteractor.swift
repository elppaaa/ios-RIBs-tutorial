//
//  LoggedOutInteractor.swift
//  TicTacToe
//
//  Created by JK on 2022/01/08.
//  Copyright © 2022 Uber. All rights reserved.
//

import RIBs
import RxSwift

/// router 와 통신할 때에 사용
protocol LoggedOutRouting: ViewableRouting {
    // TODO: Declare methods the interactor can invoke to manage sub-tree via the router.
}

/// ViewController 와 통신할 때에 사용.
protocol LoggedOutPresentable: Presentable {
    var listener: LoggedOutPresentableListener? { get set }
    // TODO: Declare methods the interactor can invoke the presenter to present data.
}

/// Router 와 연결되어 있으며, Router 에서 부모 RIB 에 데이터 전달할때 Listener 사용.
protocol LoggedOutListener: AnyObject {
    // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class LoggedOutInteractor: PresentableInteractor<LoggedOutPresentable>, LoggedOutInteractable {
  
    weak var router: LoggedOutRouting?
    weak var listener: LoggedOutListener?

    // TODO: Add additional dependencies to constructor. Do not perform any logic
    // in constructor.
    override init(presenter: LoggedOutPresentable) {
        super.init(presenter: presenter)
        presenter.listener = self
    }

    override func didBecomeActive() {
        super.didBecomeActive()
        // TODO: Implement business logic here.
    }

    override func willResignActive() {
        super.willResignActive()
        // TODO: Pause any business logic.
    }
}

extension LoggedOutInteractor: LoggedOutPresentableListener {
  func login(withPlayer1Name player1Name: String?, player2Name: String?) {
    let player1NameWithDefault = playerName(player1Name, withDefaultName: "Player 1")
    let player2NameWithDefault = playerName(player2Name, withDefaultName: "Player 2")
    
    print("\(player1NameWithDefault) vs \(player2NameWithDefault)")
  }
  
  private func playerName(_ name: String?, withDefaultName defaultName: String) -> String {
    if let name = name {
      return name.isEmpty ? defaultName : name
    } else {
      return defaultName
    }
  }
  
}
