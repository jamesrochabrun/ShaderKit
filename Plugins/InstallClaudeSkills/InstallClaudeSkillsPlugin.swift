//
//  InstallClaudeSkillsPlugin.swift
//  ShaderKit
//
//  Command plugin that copies the agent skills bundled with this package
//  into the consuming project's skills directories, where coding agents
//  discover them: `.claude/skills/` (Claude Code) and, when a `.codex/`
//  directory exists or `--codex` is passed, `.codex/skills/` (Codex).
//
//  From a package:  swift package --allow-writing-to-package-directory install-claude-skills
//  From Xcode:      right-click the ShaderKit package → InstallClaudeSkills
//

import Foundation
import PackagePlugin

@main
struct InstallClaudeSkillsPlugin: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) async throws {
    try SkillInstaller.install(intoProjectAt: context.package.directory.string, arguments: arguments)
  }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension InstallClaudeSkillsPlugin: XcodeCommandPlugin {
  func performCommand(context: XcodePluginContext, arguments: [String]) throws {
    try SkillInstaller.install(intoProjectAt: context.xcodeProject.directory.string, arguments: arguments)
  }
}
#endif

enum SkillInstaller {
  struct InstallError: Error, CustomStringConvertible {
    let description: String
  }

  /// The skills shipped with this package, located relative to this source
  /// file's compile-time path. Plugins build from source on the consumer's
  /// machine, so `#filePath` points into the package checkout whether that
  /// is a local clone, `.build/checkouts`, or Xcode's SourcePackages.
  static func bundledSkillsDirectory() throws -> URL {
    let packageRoot = URL(fileURLWithPath: #filePath)
      .deletingLastPathComponent() // InstallClaudeSkills
      .deletingLastPathComponent() // Plugins
      .deletingLastPathComponent() // package root
    let skills = packageRoot.appendingPathComponent(".claude/skills", isDirectory: true)
    guard FileManager.default.fileExists(atPath: skills.path) else {
      throw InstallError(description: "Bundled skills not found at \(skills.path)")
    }
    return skills
  }

  /// Where to install in the consuming project. Claude Code's directory is
  /// always included; Codex's is included when the project already uses
  /// Codex (a `.codex/` directory exists) or `--codex` is passed.
  static func destinationRoots(projectURL: URL, arguments: [String]) -> [URL] {
    var roots = [projectURL.appendingPathComponent(".claude/skills", isDirectory: true)]
    let codexDirectory = projectURL.appendingPathComponent(".codex", isDirectory: true)
    if arguments.contains("--codex") || FileManager.default.fileExists(atPath: codexDirectory.path) {
      roots.append(codexDirectory.appendingPathComponent("skills", isDirectory: true))
    }
    return roots
  }

  static func install(intoProjectAt projectPath: String, arguments: [String] = []) throws {
    let fileManager = FileManager.default
    let source = try bundledSkillsDirectory()
    let projectURL = URL(fileURLWithPath: projectPath)

    let skillDirectories = try fileManager
      .contentsOfDirectory(at: source, includingPropertiesForKeys: [.isDirectoryKey])
      .filter { fileManager.fileExists(atPath: $0.appendingPathComponent("SKILL.md").path) }
      .sorted { $0.lastPathComponent < $1.lastPathComponent }

    guard !skillDirectories.isEmpty else {
      throw InstallError(description: "No skills found in \(source.path)")
    }

    var installed: [String] = []
    for destinationRoot in destinationRoots(projectURL: projectURL, arguments: arguments) {
      try fileManager.createDirectory(at: destinationRoot, withIntermediateDirectories: true)

      for skill in skillDirectories {
        let destination = destinationRoot.appendingPathComponent(skill.lastPathComponent, isDirectory: true)
        guard skill.standardizedFileURL.path != destination.standardizedFileURL.path else {
          print("Skill '\(skill.lastPathComponent)' is already in place (running inside the ShaderKit package).")
          continue
        }
        if fileManager.fileExists(atPath: destination.path) {
          try fileManager.removeItem(at: destination)
        }
        try fileManager.copyItem(at: skill, to: destination)
        installed.append(skill.lastPathComponent)
        print("Installed skill '\(skill.lastPathComponent)' → \(destination.path)")
      }
    }

    if !installed.isEmpty {
      print("Done. Restart your agent session to pick up the new skill\(installed.count == 1 ? "" : "s").")
    }
  }
}
