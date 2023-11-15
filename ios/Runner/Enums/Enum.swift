//
//  Enum.swift
//  Runner
//
//  Created by ahhyun lee on 11/15/23.
//

import Foundation

enum PayloadType {
    case bytes, stream, file
}

enum Status {
    case inProgress(Progress), success, failure, canceled
}
