//
//  TextMessagingView.swift
//  Linguista
//
//  Created by Daniel Grant on 2/10/25.
//

import Foundation
import SwiftUI

struct TextMessagingView: View {
        
    var body: some View {
        VStack{
            MessageListView()
            
            MessageInputView()
        }
    }
}

struct TextMessagingView_Previews: PreviewProvider {
    static var previews: some View {
        TextMessagingView()
    }
}
