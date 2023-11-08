//
//  RijksSecretsContainer.swift
//  RijksDataBrowser
//
//  Created by Artem Garmash on 08/11/2023.
//

import Foundation

protocol RijksSecretsContainerProtocol {
    var apiKey: String { get }
}

class RijksSecretsContainer: RijksSecretsContainerProtocol {
    var apiKey: String { "0fiuZFh4" }
}
