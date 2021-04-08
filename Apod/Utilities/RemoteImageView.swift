//
//  RemoteImageView.swift
//  Apod
//
//  Created by Pranith Margam on 08/04/21.
//

import UIKit

class RemoteImageView: UIImageView {
    
    private func image(at url: NSURL) -> UIImage? {
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsUrl.appendingPathComponent(url.lastPathComponent ?? "")
            do {
                let imageData = try Data(contentsOf: fileURL)
                return UIImage(data: imageData)
            } catch {}
        }
        return nil
    }
    
    func setImage(with url: NSURL,g completion:@escaping () -> Swift.Void) {
        
        if let cachedImage = image(at: url) {
            self.setImageOnMainThread(with: cachedImage,completion: completion)
            return
        }
    
        URLSession.shared.dataTask(with: url as URL) { (data, response, error) in
            guard let responseData = data, let image = UIImage(data: responseData),error == nil else {
                self.setImageOnMainThread(with: nil,completion: completion)//have to update with placeholder image
                return
            }
            self.saveImageInDocumentDirectory(image: image,at: url)
            self.setImageOnMainThread(with: image,completion: completion)
        }.resume()
    }
    
    private func setImageOnMainThread(with image: UIImage?,completion:@escaping () -> Swift.Void) {
        DispatchQueue.main.async {
            self.image = image
            completion()
        }
    }
    
    private func saveImageInDocumentDirectory(image: UIImage,at url: NSURL) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!;
        let fileURL = documentsUrl.appendingPathComponent(url.lastPathComponent ?? "")
        if  let imageData = image.pngData() {
            do {
                try imageData.write(to: fileURL, options: .atomic)
            }catch {
                print("failed to save image")
            }
        }
    }
}
