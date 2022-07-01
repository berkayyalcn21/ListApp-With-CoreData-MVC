//
//  ViewController.swift
//  ListApp
//
//  Created by Berkay on 1.07.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var data = [NSManagedObject]()
    var alertController = UIAlertController()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        fetch()
    }
    
    @IBAction func didAddBarButtonItemTapped(_ sender: UIBarButtonItem){
        presentAddAlert()
    }
    
    @IBAction func didDeleteBarButtonItemTapped(_ sender: UIBarButtonItem){
        presentAlert(title: "Öğeleri Sil", message: "Listedeki bütün öğeleri silmek istediğinize emin misiniz?", defaultButton: "Sil", cancelButton: "Vazgeç") { _ in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            for i in self.data{
                context?.delete(i)
            }
            try? context?.save()
            self.fetch()
        }
    }
    
    func presentAddAlert(){
        presentAlert(title: "Yeni Değer Ekle", defaultButton: "Ekle", cancelButton: "Vazgeç", isTextFieldAvaible: true) { _ in
            let text = self.alertController.textFields?.first?.text
            if text != ""{
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                let context = appDelegate?.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "ListItem", in: context!)
                let listItem = NSManagedObject(entity: entity!, insertInto: context)
                listItem.setValue(text, forKey: "title")
                
                try? context?.save()
                
                self.fetch()
            }else{
                self.presentWarningAlert()
            }
        }
    }
    
    func presentWarningAlert(){
        presentAlert(title: "UYARI!", message: "Liste elemanı boş olamaz!", cancelButton: "TAMAM")
    }
    
    func presentAlert(title: String?, message: String? = nil, preferredStyle: UIAlertController.Style = .alert, defaultButton: String? = nil, cancelButton: String?, isTextFieldAvaible: Bool = false, defaultButtonHandler: ((UIAlertAction) -> Void)? = nil){
        
        alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: preferredStyle)
        
        if defaultButton != nil{
            let defaultButton = UIAlertAction(title: defaultButton, style: .default, handler: defaultButtonHandler)
            
            alertController.addAction(defaultButton)
        }
        
        let cancelButton = UIAlertAction(title: cancelButton, style: .cancel)
        
        if isTextFieldAvaible {
            alertController.addTextField()
        }
        
        alertController.addAction(cancelButton)
        
        present(alertController, animated: true)
    }
    
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        data = try! context!.fetch(fetchRequest)
        tableView.reloadData()
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal,
                                             title: "Sil") { _, _, _ in
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            let context = appDelegate?.persistentContainer.viewContext
            context?.delete(self.data[indexPath.row])
            try? context?.save()
            self.fetch()
        }
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal,
                                            title: "Düzenle") { _, _, _ in
            
            self.presentAlert(title: "Yeni Değer Ekle", defaultButton: "Düzenle", cancelButton: "Vazgeç", isTextFieldAvaible: true) { _ in
                let text = self.alertController.textFields?.first?.text
                if text != ""{
                    let appDelegate = UIApplication.shared.delegate as? AppDelegate
                    let context = appDelegate?.persistentContainer.viewContext
                    self.data[indexPath.row].setValue(text, forKey: "title")
                    if context! .hasChanges{
                        try? context?.save()
                    }
                    self.tableView.reloadData()
                    
                } else{
                    self.presentWarningAlert()
                }
                
            }
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return config
    }
}

