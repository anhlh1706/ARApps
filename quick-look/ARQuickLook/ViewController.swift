//
//  ViewController.swift
//  ARQuickLook
//
//  Created by Lê Hoàng Anh on 10/09/2020.
//  Copyright © 2020 Lê Hoàng Anh. All rights reserved.
//

import UIKit
import QuickLook

struct ObjectModel {
    let title: String
    var image: UIImage? {
        UIImage(named: "\(title).jpg")
    }
}

final class ViewController: UIViewController {
    
    let models = [ "cupandsaucer", "gramophone", "plantpot", "redchair", "teapot", "tulip", "wateringcan"].map { ObjectModel(title: $0) }
    
    var thumnailIndex = 0
    
    let tableView = UITableView(frame: .zero, style: .plain)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.imageView?.image = model.image
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        thumnailIndex = indexPath.row
        
        let previewController = QLPreviewController()
        previewController.delegate = self
        previewController.dataSource = self
        present(previewController, animated: true)
    }
}

extension ViewController: QLPreviewControllerDelegate, QLPreviewControllerDataSource {
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let url = Bundle.main.url(forResource: models[thumnailIndex].title, withExtension: "usdz")!
        return url as QLPreviewItem
    }
    
}
