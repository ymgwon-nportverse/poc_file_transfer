//
//  OS\Log.swift
//  Runner
//
//  Created by ahhyun lee on 12/5/23.
//

import Foundation
import OSLog

// 메시지 로깅이 필요한 위치에서 아래 메서드를 호출
//os_log(.fault, log: .data, OSLogMessage.artworkIsNil)
extension OSLog {
  private static var subsystem = Bundle.main.bundleIdentifier!
  static let ui = OSLog(subsystem: subsystem, category: "UI")
  static let data = OSLog(subsystem: subsystem, category: "Data")
}

// Debug: 개발 중 코드 디버깅 시 사용할 수 있는 유용한 정보
// Info: 문제 해결 (트러블슈팅) 시 활용할 수 있는, 도움이 되지만 필수적이지 않은 정보
// Notice (기본값): 문제 해결에 필수적인 정보. Failure를 초래할 수 있는 정보
// Error: 코드 실행 중 나타난 에러. 활동 객체가 존재하는 경우 관련 프로세스 체인에 대한 정보 캡처
// Fault: 코드 속의 폴트 (Faults) 및 버그 관련 정보. 활동 객체가 존재하는 경우 관련 프로세스 체인에 대한 정보 캡처


// 1. os_log(_:)
// os_log("artWork is nil.")

// 2. os_log(_:log:_:)
// os_log(.fault, log: .default, "artwork is Nil.")
