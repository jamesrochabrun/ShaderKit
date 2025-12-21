//
//  ContentView.swift
//  ShaderKitDemo
//
//  Main navigation hub for ShaderKit demos
//

import SwiftUI

enum DemoCategory: String, CaseIterable, Identifiable {
  case specialShaders = "Special Shaders"
  case hologramCards = "Hologram Cards"
  
  var id: String { rawValue }
  
  var description: String {
    switch self {
    case .specialShaders:
      return "12 Pokemon-style holographic effects"
    case .hologramCards:
      return "6 complete card demos with layered effects"
    }
  }
  
  var icon: String {
    switch self {
    case .specialShaders:
      return "sparkles"
    case .hologramCards:
      return "rectangle.stack.fill"
    }
  }
  
  @ViewBuilder
  var destination: some View {
    switch self {
    case .specialShaders:
      SpecialShadersDemo()
    case .hologramCards:
      HologramDemoView()
    }
  }
}

struct ContentView: View {
  var body: some View {
    NavigationStack {
      List(DemoCategory.allCases) { category in
        NavigationLink(destination: category.destination) {
          HStack(spacing: 16) {
            Image(systemName: category.icon)
              .font(.title2)
              .foregroundStyle(.blue)
              .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
              Text(category.rawValue)
                .font(.headline)
              Text(category.description)
                .font(.caption)
                .foregroundStyle(.secondary)
            }
          }
          .padding(.vertical, 8)
        }
      }
      .navigationTitle("ShaderKit Demos")
    }
  }
}

#Preview {
  ContentView()
}
