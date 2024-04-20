//
//  DetailsVC.swift
//  tbc-1818
//
//  Created by Giorgi Michitashvili on 4/20/24.
//

import UIKit

var title1 = UILabel()
var potunia1 = UIImage()

var receivedData: String?

    func sendData(data: String) {
        receivedData = data
    }

class DetailsVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        configureTitle1()
        sendData(data: receivedData ?? "not found 404")
        
        
    }
    
    func configureTitle1() {
        title1.text = "Details"
        title1.textColor = UIColor.black
        title1.font = UIFont(name: "SpaceGrotesk-SemiBold", size: 24)
        view.addSubview(title1)
        title1.translatesAutoresizingMaskIntoConstraints = false
        title1.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        title1.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -711).isActive = true
        title1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 24).isActive = true
        title1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -271).isActive = true
    }
    
    
    
    
}


