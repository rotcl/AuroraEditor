//
//  AccountListItem.swift
//  AuroraEditorModules/AppPreferences
//
//  Created by Nanshi Li on 2022/04/01.
//

import SwiftUI

struct AccountListItem: View {

    var gitClientName: String
    var gitClientSymbol: String
    var clientId: String

    var body: some View {
        HStack {
            if clientId == "auroraEditor" {
                Image(systemName: gitClientSymbol)
                    .resizable()
                    .frame(width: 28.0, height: 28.0)
            } else {
                Image(gitClientSymbol)
                    .resizable()
                    .frame(width: 28.0, height: 28.0)
            }
            Text(gitClientName)
                .font(.system(size: 12))
        }
    }
}
