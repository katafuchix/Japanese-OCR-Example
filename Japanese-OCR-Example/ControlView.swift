//
//  ControlView.swift
//  Japanese-OCR-Example
//
//  Created by cano on 2023/12/30.
//

import SwiftUI

struct ControlView: View {
    
    var startHandler: (() -> Void)
    var stopHandler: (() -> Void)
    
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 42) {
                Button("Start") { startHandler() }
                Button("Stop")  { stopHandler() }
            }.padding(24)
        }
    }
}

#Preview {
    ControlView(startHandler: {}, stopHandler: {})
}
