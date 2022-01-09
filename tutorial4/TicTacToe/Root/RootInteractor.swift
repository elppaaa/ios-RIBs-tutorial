//
//  Copyright (c) 2017. Uber Technologies
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import RIBs
import RxSwift
import Foundation

protocol RootRouting: ViewableRouting {
  func routeToLoggedIn(withPlayer1Name player1Name: String, player2Name: String) -> LoggedInActionableItem
}

protocol RootPresentable: Presentable {
  var listener: RootPresentableListener? { get set }
  // TODO: Declare methods the interactor can invoke the presenter to present data.
}

protocol RootListener: AnyObject {
  // TODO: Declare methods the interactor can invoke to communicate with other RIBs.
}

final class RootInteractor: PresentableInteractor<RootPresentable>, RootInteractable, RootPresentableListener {
  
  weak var router: RootRouting?
  
  weak var listener: RootListener?
  
  // TODO: Add additional dependencies to constructor. Do not perform any logic
  // in constructor.
  override init(presenter: RootPresentable) {
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
  
  // MARK: - LoggedOutListener
  
  func didLogin(withPlayer1Name player1Name: String, player2Name: String) {
    let loggedInActionableItem = router?.routeToLoggedIn(withPlayer1Name: player1Name, player2Name: player2Name)
    if let loggedInActionableItem = loggedInActionableItem {
      loggedInActionableItemSubject.onNext(loggedInActionableItem)
    }
  }
  
  
  private let loggedInActionableItemSubject = ReplaySubject<LoggedInActionableItem>.create(bufferSize: 1)
}

/// `ActionableItem` 을 전달하는 것이 `Interactor` 의 역할
/// `waitForLogin()` 함수는 `loggedInActionableItemSubject` 의 map 하여 방출한다.
/// `loggedInActionableItemSubject` 로그인 이후 방출된다.
/// 로그인이 이미 된 상태에서는 `loggedInActionableItemSubject` 가 버퍼로 차있기 때문에 바로 전달된다.
/// 이후 최초 표시되는 `LoggedOut` RIB 이 표시된다.
extension RootInteractor: RootActionableItem {
  func waitForLogin() -> Observable<(LoggedInActionableItem, ())> {
    return loggedInActionableItemSubject
      .map { (loggedInItem: LoggedInActionableItem) -> (LoggedInActionableItem, ()) in
        (loggedInItem, ())
      }
  }
}

/// 링크를 열면 `AppDelegate.application(_:open:options:)` 를 통해
/// `URLHandler` 가 호출된다.
/// `URLHandler` 에서는 `LaunchGameWorkflow` 를 생성해서 flow 를 통작한다.
extension RootInteractor: URLHandler {
  func handle(_ url: URL) {
    let launchGameWorkflow = LaunchGameWorkflow(url: url)
    /// Workflow 에 따라 ActionableItem 이 전달된다.
    /// `Workflow` 가 갖고있는 subject 로 subscribe 시에 최초 `RootActionableItem` 이 전달된다.
    /// subject 로 `RootActionableItem` 이 전달됬으니. `RootActionableItem.waitForLogin()` 이 호출되고, ` Observable<(LoggedInActionableItem, ())>` 을 반환한다.
    /// 반환된 `LoggedInActionableItem` 을 받아 `loggedInItem.launchGame(with:)` 가 호출된다.
    /// 마지막에는 동일한 `(LoggedInActionableItem, ())` 을 반환하고 종료된다.
    launchGameWorkflow
      .subscribe(self)
      .disposeOnDeactivate(interactor: self)
  }
}
