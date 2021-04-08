//
//  ViewController.swift
//  Apod
//
//  Created by Pranith Margam on 08/04/21.
//

import UIKit

class ViewController: UIViewController {

    var imageView: RemoteImageView! = {
        let image = RemoteImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    var errorLabel: UILabel! = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .red
        return label
    }()
    
    var titleLabel:UILabel! = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    var discriptionLabel:UILabel! = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        ApodClient(session: URLSession.shared).fetchAPODData { [weak self] (result) in
            self?.handleResponse(with: result)
        }
    }
    
    fileprivate func setUpUI() {
        self.view.backgroundColor = .systemGray2
        self.view.addSubview(imageView)
        
        let verticalStackView = UIStackView()
        verticalStackView.axis = .vertical
        verticalStackView.alignment = .fill
        verticalStackView.distribution = .equalSpacing
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.spacing = 12
        
        verticalStackView.addArrangedSubview(titleLabel)
        verticalStackView.addArrangedSubview(discriptionLabel)
        verticalStackView.addArrangedSubview(errorLabel)
        
        self.view.addSubview(verticalStackView)
        
        let padding: CGFloat = 24.0
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            imageView.widthAnchor.constraint(equalTo: self.view.widthAnchor),

            verticalStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: padding),
            verticalStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -padding),
            verticalStackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        ])
    }
    
    fileprivate func handleResponse(with result:APIResult<APOD>) {
        switch result {
        case .sucesss(let apodData):
           showAPODOnUI(apodData)

        case .failure(let error):
            switch error {
            case .connectionError( _):
                guard let lastSavedAPod = APOD.lastSavedApod() else {
                    self.errorLabel.text = "We are not connected to the internet.Please connect to internet"
                    break
                }
                if !ApodClient.isDateInToday(dateString: lastSavedAPod.date) {
                    self.errorLabel.text = "We are not connected to the internet, showing you the last image we have."
                }
                showAPODOnUI(lastSavedAPod)
            default:
                break
            }
        }
    }
    
    fileprivate func showAPODOnUI(_ apod: APOD) {
        if let imageUrl = NSURL(string: apod.url) {
            self.imageView.setImage(with: imageUrl) {
                self.titleLabel.text = apod.title
                self.discriptionLabel.text = apod.explanation
            }
        }
    }
}
