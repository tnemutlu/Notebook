//
//  detailsVC.swift
//  NoteBook
//
//  Created by TANRIKUT NEMUTLU on 19.05.2020.
//  Copyright © 2020 TANRIKUT NEMUTLU. All rights reserved.
//

import UIKit
import CoreData

class detailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var tcnumberText: UITextField!
    @IBOutlet weak var birthdayText: UITextField!
    @IBOutlet weak var ibanText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var choosenDatabase = ""
    var choosenDatabaseId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if choosenDatabase != "" {
            
            saveButton.isHidden = true
            
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Database")
        let idString = choosenDatabaseId?.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
        fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        nameText.text = name
                    }
                    if let birthday = result.value(forKey: "birthday") as? String {
                        birthdayText.text = birthday
                    }
                    if let tcNumber = result.value(forKey: "tcnumber") as? Int {
                        tcnumberText.text = String(tcNumber)
                    }
                    if let imageData = result.value(forKey: "image") as? Data {
                        let image = UIImage(data: imageData)
                    }
                    }
                }
            } catch {
                print("error")
            }
        
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
    }

    @objc func selectImage () {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func hideKeyboard () {
        view.endEditing(true)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newDatabase = NSEntityDescription.insertNewObject(forEntityName: "Database", into: context)
        
        newDatabase.setValue(nameText.text!, forKey: "name")
        newDatabase.setValue(birthdayText.text!, forKey: "birthday")
        newDatabase.setValue(UUID(), forKey: "id")
        
        if let tcNumber = Int(tcnumberText.text!) {
        newDatabase.setValue(tcNumber, forKey: "tcnumber")
    }
    
        if let ibanNum = Int(ibanText.text!) {
        newDatabase.setValue(ibanNum, forKey: "iban")
    }
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newDatabase.setValue(data, forKey: "image")
        
        
        do {
        try context.save()
            print("success")
        } catch {
        print ("error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
}
