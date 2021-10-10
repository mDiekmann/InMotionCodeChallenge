//
//  ViewController.swift
//  InMotionCodeChallenge
//
//  Created by Michael Diekmann on 10/6/21.
//

import UIKit
import Combine

class ViewController: UIViewController {
    private var cancellables = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        apiClient.getImageList(currentPage: 0, fetchLimit: 20)
            .sink(receiveCompletion: { result in
                    print(result)
                },
                receiveValue: { value in
            
                })
            .store(in: &cancellables)
    }
}

