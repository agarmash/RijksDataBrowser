//
//  RijksSecretsContainerStub.swift
//  RijksDataBrowserTests
//
//  Created by Artem Garmash on 08/11/2023.
//

import Foundation
@testable import RijksDataBrowser

class RijksSecretsContainerStub: RijksSecretsContainerProtocol {
    var apiKey: String { "secret" }
}
