//
//  LoggedInRouter.swift
//  TicTacToe
//
//  Created by JK on 2022/01/09.
//  Copyright © 2022 Uber. All rights reserved.
//

import RIBs

protocol LoggedInInteractable: Interactable, OffGameListener, TicTacToeListener {
  var router: LoggedInRouting? { get set }
  var listener: LoggedInListener? { get set }
}

/// LoggedInViewController을 채택하고 있는 RootViewController 가
/// preset, dismiss 함수를 이미 구현하고 있기 때문에 추가적으로 작성할 필요가 없다.
protocol LoggedInViewControllable: ViewControllable {
  // TODO: Declare methods the router invokes to manipulate the view hierarchy. Since
  // this RIB does not own its own view, this protocol is conformed to by one of this
  // RIB's ancestor RIBs' view.
  func present(viewController: ViewControllable)
  func dismiss(viewController: ViewControllable)
}

final class LoggedInRouter: Router<LoggedInInteractable>, LoggedInRouting {
  func routeToTicTacToe() {
    if let currentChild = currentChild {
      detachChild(currentChild)
      cleanupViews()
    }
    attachTicTacToe()
  }
  
  func routeToOffGame() {
    if let currentChild = currentChild {
      detachChild(currentChild)
      cleanupViews()
    }
    attachOffGame()
  }
  
  
  
  // TODO: Constructor inject child builder protocols to allow building children.
  init(interactor: LoggedInInteractable,
       viewController: LoggedInViewControllable,
       offGameBuilder: OffGameBuildable,
       tictactoeBuilder: TicTacToeBuildable) {
    self.viewController = viewController
    self.offGameBuilder = offGameBuilder
    self.tictactoeBuilder = tictactoeBuilder
    super.init(interactor: interactor)
    interactor.router = self
  }
  
  func cleanupViews() {
    // TODO: Since this router does not own its view, it needs to cleanup the views
    // it may have added to the view hierarchy, when its interactor is deactivated.
    if let currentChild = currentChild {
      viewController.dismiss(viewController: currentChild.viewControllable)
    }
  }
  
  func startTicTacToe() {
    cleanupViews()
  }
  
  
  override func didLoad() {
    super.didLoad()
    attachOffGame()
  }
  
  // MARK: - Private
  
  private let viewController: LoggedInViewControllable
  private let offGameBuilder: OffGameBuildable
  private let tictactoeBuilder: TicTacToeBuildable
  private var currentChild: ViewableRouting?
  
  private func attachOffGame() {
    let offGame = offGameBuilder.build(withListener: interactor)
    self.currentChild = offGame
    attachChild(offGame)
    viewController.present(viewController: offGame.viewControllable)
  }
  
  private func attachTicTacToe() {
    let tictactoe = tictactoeBuilder.build(withListener: interactor)
    self.currentChild = tictactoe
    attachChild(tictactoe)
    viewController.present(viewController: tictactoe.viewControllable)
  }
}

