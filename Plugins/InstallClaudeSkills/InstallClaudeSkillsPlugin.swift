//
//  InstallClaudeSkillsPlugin.swift
//  ShaderKit
//
//  Command plugin that copies the Claude Code skills bundled with this
//  package into the consuming project's `.claude/skills/` directory, where
//  Claude Code discovers them.
//
//  From a package:  swift package --allow-writing-to-package-directory install-claude-skills
//  From Xcode:      right-click the ShaderKit package → InstallClaudeSkills
//

import Foundation
import PackagePlugin

@main
struct InstallClaudeSkillsPlugin: CommandPlugin {
  func performCommand(context: PluginContext, arguments: [String]) async throws {
    try SkillInstaller.install(intoProjectAt: context.package.directory.string)
  }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension InstallClaudeSkillsPlugin: XcodeCommandPlugin {
  func performCommand(context: XcodePluginContext, arguments: [String]) throws {
    try SkillInstaller.install(intoProjectAt: context.xcodeProject.directory.string)
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

  static func install(intoProjectAt projectPath: String) throws {
    let fileManager = FileManager.default
    let source = try bundledSkillsDirectory()
    let destinationRoot = URL(fileURLWithPath: projectPath)
      .appendingPathComponent(".claude/skills", isDirectory: true)

    let skillDirectories = try fileManager
      .contentsOfDirectory(at: source, includingPropertiesForKeys: [.isDirectoryKey])
      .filter { fileManager.fileExists(atPath: $0.appendingPathComponent("SKILL.md").path) }
      .sorted { $0.lastPathComponent < $1.lastPathComponent }

    guard !skillDirectories.isEmpty else {
      throw InstallError(description: "No skills found in \(source.path)")
    }

    try fileManager.createDirectory(at: destinationRoot, withIntermediateDirectories: true)

    var installed: [String] = []
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

    if !installed.isEmpty {
      print("Done. Restart your Claude Code session to pick up the new skill\(installed.count == 1 ? "" : "s").")
    }
  }
}
