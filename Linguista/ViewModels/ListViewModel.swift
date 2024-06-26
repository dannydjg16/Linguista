//
//  ListViewModel.swift
//  Linguista
//
//  Created by Daniel Grant on 6/25/24.
//

import Foundation
import SwiftUI

class ListViewModel: ObservableObject {
    @Published var selectedItem: String? = nil
}
