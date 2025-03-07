//
//  EditorAccountModel.swift
//  AuroraEditor
//
//  Created by Nanashi Li on 2022/10/28.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import Foundation

class EditorAccountModel: ObservableObject {

    private var prefs: AppPreferencesModel = .shared

    private let keychain = AuroraEditorKeychain()

    @Published
    var dismissDialog: Bool

    init(dismissDialog: Bool) {
        self.dismissDialog = dismissDialog
    }

    func loginAuroraEditor(email: String,
                           password: String) {

        let parameters: [String: Any] = [
            "email": email,
            "password": password
        ]

        AuroraNetworking().request(baseURL: Constants.auroraEditorBaseURL,
                                   path: Constants.login,
                                   useAuthType: .none,
                                   method: .POST,
                                   parameters: parameters,
                                   completionHandler: { completion in
            switch completion {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let login = try decoder.decode(AELogin.self, from: data)

                    DispatchQueue.main.async {
                        self.prefs.preferences.accounts.sourceControlAccounts.gitAccount.append(
                            SourceControlAccounts(id: login.user.id,
                                                  gitProvider: "Aurora Editor",
                                                  gitProviderLink: "https://auroraeditor.com",
                                                  gitProviderDescription: "Official Aurora Editor Account",
                                                  gitAccountName: "\(login.user.firstName) \(login.user.lastName)",
                                                  gitAccountEmail: login.user.email,
                                                  gitAccountUsername: "",
                                                  gitAccountImage: login.user.profileImage,
                                                  gitCloningProtocol: false,
                                                  gitSSHKey: "",
                                                  isTokenValid: true)
                        )

                        self.dismissDialog = false
                    }
                    self.keychain.set(login.accessToken, forKey: "auroraeditor_access_\(email)")
                    self.keychain.set(login.refreshToken, forKey: "auroraeditor_refresh_\(email)")
                } catch {

                }
            case .failure(let failure):
                Log.error(failure)
            }
        })
    }

    func loginGitlab(gitAccountName: String,
                     accountToken: String,
                     accountName: String) {
        let gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        let config = GitlabTokenConfiguration(accountToken)
        GitlabAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.id == gitAccountName.lowercased() }) {
                    Log.warning("Account with the username already exists!")
                } else {
                    Log.info(user)
                    self.prefs.preferences.accounts.sourceControlAccounts.gitAccount.append(
                        SourceControlAccounts(id: gitAccountName.lowercased(),
                                              gitProvider: "Gitlab",
                                              gitProviderLink: "https://gitlab.com",
                                              gitProviderDescription: "Gitlab",
                                              gitAccountName: gitAccountName,
                                              gitAccountEmail: "user.email",
                                              gitAccountUsername: "user.username",
                                              gitAccountImage: "user.avatarURL?.absoluteString!",
                                              gitCloningProtocol: true,
                                              gitSSHKey: "",
                                              isTokenValid: true))
                    self.keychain.set(accountToken, forKey: "gitlab_\(accountName)")
                    self.dismissDialog = false
                }
            case .failure(let error):
                Log.error(error)
            }
        }
    }

    func loginGitlabSelfHosted(gitAccountName: String,
                               accountToken: String,
                               enterpriseLink: String) {
        let gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        let config = GitlabTokenConfiguration(accountToken,
                                              url: enterpriseLink )
        GitlabAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.id == gitAccountName.lowercased() }) {
                    Log.warning("Account with the username already exists!")
                } else {
                    Log.info(user)
                    self.prefs.preferences.accounts.sourceControlAccounts.gitAccount.append(
                        SourceControlAccounts(id: gitAccountName.lowercased(),
                                              gitProvider: "Gitlab",
                                              gitProviderLink: enterpriseLink,
                                              gitProviderDescription: "Gitlab",
                                              gitAccountName: gitAccountName,
                                              gitAccountEmail: "user.email!",
                                              gitAccountUsername: "user.username",
                                              gitAccountImage: "user.avatarURL?.relativeString!",
                                              gitCloningProtocol: true,
                                              gitSSHKey: "",
                                              isTokenValid: true))
                    self.keychain.set(accountToken, forKey: "gitlab_\(gitAccountName)_hosted")
                    self.dismissDialog = false
                }
            case .failure(let error):
                Log.error(error)
            }
        }
    }

    func loginGithub(gitAccountName: String,
                     accountToken: String) {
        let gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        let config = GithubTokenConfiguration(accountToken)
        GithubAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.id == gitAccountName.lowercased() }) {
                    Log.warning("Account with the username already exists!")
                } else {
                    Log.info(user)
                    DispatchQueue.main.async {
                        self.prefs.preferences.accounts.sourceControlAccounts.gitAccount.append(
                            SourceControlAccounts(id: gitAccountName.lowercased(),
                                                  gitProvider: "GitHub",
                                                  gitProviderLink: "https://github.com",
                                                  gitProviderDescription: "GitHub",
                                                  gitAccountName: gitAccountName,
                                                  gitAccountEmail: user.email ?? "Not Found",
                                                  gitAccountUsername: user.login!,
                                                  gitAccountImage: user.avatarURL!,
                                                  gitCloningProtocol: true,
                                                  gitSSHKey: "",
                                                  isTokenValid: true))
                        self.keychain.set(accountToken, forKey: "github_\(user.login!)")
                    }
                    self.dismissDialog.toggle()
                }
            case .failure(let error):
                Log.error(error)
            }
        }
    }

    func loginGithubEnterprise(gitAccountName: String,
                               accountToken: String,
                               accountName: String,
                               enterpriseLink: String) {
        let gitAccounts = prefs.preferences.accounts.sourceControlAccounts.gitAccount

        let config = GithubTokenConfiguration(accountToken,
                                              url: enterpriseLink )
        GithubAccount(config).me { response in
            switch response {
            case .success(let user):
                if gitAccounts.contains(where: { $0.id == gitAccountName.lowercased() }) {
                    Log.warning("Account with the username already exists!")
                } else {
                    Log.info(user)
                    self.prefs.preferences.accounts.sourceControlAccounts.gitAccount.append(
                        SourceControlAccounts(id: gitAccountName.lowercased(),
                                              gitProvider: "GitHub",
                                              gitProviderLink: enterpriseLink,
                                              gitProviderDescription: "GitHub",
                                              gitAccountName: gitAccountName,
                                              gitAccountEmail: user.email!,
                                              gitAccountUsername: user.login!,
                                              gitAccountImage: user.avatarURL!,
                                              gitCloningProtocol: true,
                                              gitSSHKey: "",
                                              isTokenValid: true))
                    self.keychain.set(accountToken, forKey: "github_\(accountName)_enterprise")
                    self.dismissDialog = false
                }
            case .failure(let error):
                Log.error(error)
            }
        }
    }
}
