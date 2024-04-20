//
//  ViewController.swift
//  tbc-1818
//
//  Created by Giorgi Michitashvili on 4/20/24.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    protocol DataDelegate: AnyObject {
        func sendData(data: String)
    }
    
    weak var delegate: DataDelegate?

    
   
    
    
    
    
    var collectionView: UICollectionView!
    var informacia: List?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        
        /* layout */
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        
        
        /* collectionView settings */
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        view.addSubview(collectionView)
        
    }
    
    func fetchData() {
        Task {
            do {
                informacia = try await getInfoFromWeb()
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            } catch ImediError.InvalidData{
                print("invaliduri data o")
            } catch ImediError.InvalidResponse{
                print("indaliduri responsio")
            } catch ImediError.URLError{
                print("linki ragac ver ari pormashi")
            } catch {
                print("unexpected error")
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.layer.cornerRadius = 15
        
        if let photoUrl = informacia?.list[indexPath.item].photoUrl {
            if let url = URL(string: photoUrl) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        let image = UIImage(data: data)
                        DispatchQueue.main.async {
                            let imageView = UIImageView(image: image)
                            imageView.contentMode = .scaleAspectFill
                            imageView.clipsToBounds = true
                            imageView.frame = cell.layer.frame
                            imageView.layer.cornerRadius = 15
                            cell.backgroundView = imageView
                            
                            let blurEffect = UIBlurEffect(style: .regular)
                                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
                                    blurEffectView.frame = imageView.bounds
                                    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                                    imageView.addSubview(blurEffectView)
                                    blurEffectView.alpha = 0.3
                        }
                    }
                }
            }
        }
        
        if let title = informacia?.list[indexPath.item].title {
            let teqsti = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.width / 1.075, height: cell.frame.height / 2.84))
            teqsti.numberOfLines = 0
            teqsti.text = title
            teqsti.font = UIFont(name: "FiraGO-Medium", size: 14)
            teqsti.textAlignment = .center
            teqsti.textColor = UIColor.white
            cell.contentView.addSubview(teqsti)
            teqsti.translatesAutoresizingMaskIntoConstraints = false
            teqsti.topAnchor.constraint(equalTo: cell.topAnchor, constant: 35).isActive = true
            teqsti.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -35).isActive = true
            teqsti.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 16).isActive = true
            teqsti.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -7).isActive = true
        }
        
        if let time = informacia?.list[indexPath.item].time{
            let time1 = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.width / 11.6 , height: cell.frame.height / 7.71 ))
            time1.font = UIFont(name: "FiraGO-Medium", size: 12)
            time1.textAlignment = .center
            time1.text = time
            time1.textColor = UIColor.white
            cell.contentView.addSubview(time1)
            time1.translatesAutoresizingMaskIntoConstraints = false
            time1.topAnchor.constraint(equalTo: cell.topAnchor, constant: 16).isActive = true
            time1.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -78).isActive = true
            time1.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 153).isActive = true
            time1.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -145).isActive = true
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width ) / 1.15
        let height = (collectionView.frame.height) / 7.51
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let newViewController = DetailsVC()
            navigationController?.pushViewController(newViewController, animated: true)
        var yourData = String(indexPath.item)
        func someMethod() {
            delegate?.sendData(data: yourData)
        }
        someMethod()
            
        }
}


func getInfoFromWeb() async throws -> List {
    let endpoint = "https://imedinews.ge/api/categorysidebarnews/get"
    
    guard let url = URL(string: endpoint) else {
        throw ImediError.URLError
    }
    let (data, response) = try await URLSession.shared.data(from: url)
    
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        throw ImediError.InvalidResponse
    }
    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase // Use this if your JSON keys are in snake_case
        return try decoder.decode(List.self, from: data)
    } catch let error as DecodingError {
        print("Decoding error: \(error)")
        throw ImediError.InvalidData
    } catch {
        print("Unexpected error: \(error)")
        throw ImediError.InvalidData
    }
}



struct List: Codable {
    var list: [Description]
    
    struct Description: Codable {
        var title: String
        var time: String
        var url: String
        var type: Int
        var photoUrl: String
        var photoAlt: String
        
        enum CodingKeys: String, CodingKey {
            case title = "Title"
            case time = "Time"
            case url = "Url"
            case type = "Type"
            case photoUrl = "PhotoUrl"
            case photoAlt = "PhotoAlt"
        }
    }
    enum CodingKeys: String, CodingKey {
        case list = "List"
    }
}


enum ImediError: Error {
    case URLError
    case InvalidResponse
    case InvalidData
}
