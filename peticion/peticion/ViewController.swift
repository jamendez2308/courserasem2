//
//  ViewController.swift
//  peticion
//
//  Created by Mendez, Arturo {LALA} on 26/08/16.
//  Copyright © 2016 Mendez, Arturo {LALA}. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate , UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var txtIsbn: UITextField!
    @IBOutlet weak var lblBookTitle: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblAutor: UILabel!
    
    @IBOutlet var auts: NSArray!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.txtIsbn.delegate = self;
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.auts != nil){
            return (self.auts.count as Int)
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        let aut = self.auts[indexPath.row] as! NSDictionary
        cell.textLabel?.text = aut["name"] as! NSString as String
        
        return cell
        
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true);
        
        //Metodo sincrono
        let url1 = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
        let url2 = self.txtIsbn.text!
        let urls = url1 + url2
        
        let url = NSURL(string: urls)
        let datos:NSData? = NSData(contentsOfURL: url!)
        
        do{
            let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
            //Validar json correcto
            if NSJSONSerialization.isValidJSONObject(json){
                let resp = json as! NSDictionary
                //Validar si el diccionario contiene elementos
                if resp.allKeys.count > 0 {
                    let book = resp["ISBN:" + self.txtIsbn.text!] as! NSDictionary
                    //Aqui se recupera el titulo
                    self.lblBookTitle.text = book["title"] as! NSString as String
                    
                    //Aqui se recupera la portada segun especificaciones de Open Library https://openlibrary.org/dev/docs/api/covers
                    self.imgCover.image = nil
                    if let url = NSURL(string: "http://covers.openlibrary.org/b/ISBN/" + self.txtIsbn.text! + "-M.jpg") {
                        if let data = NSData(contentsOfURL: url) {
                            self.imgCover.image = UIImage(data: data)
                        }
                    }
                    
                    //Aqui recuperamos la lista de autores
                    self.auts = book["authors"] as! NSArray
                    self.lblAutor.text = "Autor:"
                    if (self.auts != nil && self.auts.count > 2){
                        self.lblAutor.text = "Autores:"
                    }
                    self.tableView.reloadData()
                }
                else{
                    msgNoEncontrado()
                }
                
            }
            else{
                msgNoEncontrado()
            }
        }
        catch _ {
            let alert = UIAlertController(title: "Petición", message: "Error de comunicación!!!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
        return false;
    }
    
    func msgNoEncontrado(){
        self.lblBookTitle.text = ""
        self.imgCover.image = nil
        self.auts = nil;
        self.tableView.reloadData()
        
        let alert = UIAlertController(title: "Busqueda", message: "ISBN No recuperado.", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

}

