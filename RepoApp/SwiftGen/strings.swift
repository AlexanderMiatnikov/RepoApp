// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum Strings {
  /// Author
  internal static let author = Strings.tr("Localizable", "author", fallback: "Author")
  /// (A-Z)
  internal static let az = Strings.tr("Localizable", "az", fallback: "(A-Z)")
  /// Cancel
  internal static let cancel = Strings.tr("Localizable", "cancel", fallback: "Cancel")
  /// Choose filter
  internal static let chooseFilter = Strings.tr("Localizable", "chooseFilter", fallback: "Choose filter")
  /// Choose sorting type
  internal static let chooseSortingType = Strings.tr("Localizable", "chooseSortingType", fallback: "Choose sorting type")
  /// Error
  internal static let error = Strings.tr("Localizable", "error", fallback: "Error")
  /// Enter author name
  internal static let labelTypeFilterAuthor = Strings.tr("Localizable", "labelTypeFilterAuthor", fallback: "Enter author name")
  /// Enter repository name
  internal static let labelTypeFilterRepository = Strings.tr("Localizable", "labelTypeFilterRepository", fallback: "Enter repository name")
  /// no description
  internal static let noDescription = Strings.tr("Localizable", "noDescription", fallback: "no description")
  /// no name
  internal static let noName = Strings.tr("Localizable", "noName", fallback: "no name")
  /// No Sorting
  internal static let noSorting = Strings.tr("Localizable", "noSorting", fallback: "No Sorting")
  /// Repository
  internal static let repository = Strings.tr("Localizable", "repository", fallback: "Repository")
  /// Search by Author
  internal static let searchPlaceholderAuthor = Strings.tr("Localizable", "searchPlaceholderAuthor", fallback: "Search by Author")
  /// Search by Repository
  internal static let searchPlaceholderRepository = Strings.tr("Localizable", "searchPlaceholderRepository", fallback: "Search by Repository")
  /// All
  internal static let segmentedControlAll = Strings.tr("Localizable", "segmentedControlAll", fallback: "All")
  /// Bitbucket
  internal static let segmentedControlBitbucket = Strings.tr("Localizable", "segmentedControlBitbucket", fallback: "Bitbucket")
  /// Github
  internal static let segmentedControlGithub = Strings.tr("Localizable", "segmentedControlGithub", fallback: "Github")
  /// Sorting
  internal static let sorting = Strings.tr("Localizable", "sorting", fallback: "Sorting")
  /// Localizable.strings
  ///   RepoApp
  /// 
  ///   Created by Aliaksandr Miatnikau on 11.09.23.
  internal static let titleRepositories = Strings.tr("Localizable", "titleRepositories", fallback: "Repositories")
  /// (Z-A)
  internal static let za = Strings.tr("Localizable", "za", fallback: "(Z-A)")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension Strings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
