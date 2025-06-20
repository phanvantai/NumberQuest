//
//  FontTestView.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI

struct FontTestView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Font Test")
                    .style(.gameTitle)
                
                Text("Chewy Font Test")
                    .font(.custom("Chewy-Regular", size: 24))
                    .foregroundColor(.blue)
                
                Text("Baloo2 Font Test")
                    .font(.custom("Baloo2-VariableFont_wght", size: 18))
                    .foregroundColor(.green)
                
                Text("System Font Test")
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(.red)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Text Styles:")
                        .font(.headline)
                    
                    Text("Game Title")
                        .style(.gameTitle)
                    
                    Text("Title")
                        .style(.title)
                    
                    Text("Body Text")
                        .style(.body)
                    
                    Text("Caption")
                        .style(.caption)
                }
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
            }
            .padding()
        }
        .background(
            LinearGradient(
                colors: [.blue, .purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview {
    FontTestView()
}
