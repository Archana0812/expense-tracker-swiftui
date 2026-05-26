//
//  FirebaseManager.swift
//  ExpenseTracker
//
//  Created by Jarvish on 16/03/26.
//

import FirebaseAuth
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    let auth = Auth.auth()
    let db = Firestore.firestore()
}
