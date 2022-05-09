//
//  HomeViewController.swift
//  TesteSolutis
//
//  Created by Virtual Machine on 12/04/22.
//

import UIKit
import SVProgressHUD

class HomeViewController: UIViewController {
    
    @IBOutlet weak var gradientView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nomeLabel: UILabel!
    @IBOutlet weak var cpfLabel: UILabel!
    @IBOutlet weak var saldoLabel: UILabel!
    
    var user: User?
    var extratoList: [Extrato] = []
    var extratoService = ExtratoService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        extratoService.delegate = self
        
        setUser()
        setGradient()
        
        SVProgressHUD.show()
        extratoService.getExtract(token: user!.token!)
    }

    @IBAction func exitClicked(_ sender: Any) {
        let alert = UIAlertController(title: "Atenção", message: "Deseja mesmo sair?", preferredStyle: .alert)
        let sairAction = UIAlertAction(title: "Sair", style: .default, handler: {_ in
            self.performSegue(withIdentifier: "loginController", sender: self)
        })
        let cancelarAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: {_ in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(sairAction)
        alert.addAction(cancelarAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func setUser() {
        nomeLabel.text = user?.nome
        cpfLabel.text = user?.cpf
        saldoLabel.text = formatarValor(valor: user!.saldo!)
    }
    
    func setGradient() {
        let gradient = CAGradientLayer()
        
        gradient.frame = self.gradientView!.bounds
        
        let color1 = UIColor(red: 177/256, green: 199/256, blue: 228/256, alpha: 1.0).cgColor
        let color2 = UIColor(red: 0/256, green: 116/256, blue: 178/256, alpha: 1.0).cgColor
        gradient.colors = [color1, color2]
        
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        self.gradientView.layer.insertSublayer(gradient, at: 0)
    }
    
    func formatarValor(valor: Double) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "pt-BR")
        formatter.numberStyle = .currency
        
        guard let formattedValue = formatter.string(from: valor as NSNumber) else { return "Erro" }
            
        return formattedValue
    }
    
    func formatarData(data: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd/MM/yyyy"

        if let date = dateFormatterGet.date(from: data) {
            return dateFormatterPrint.string(from: date)
        } else {
           return "Erro"
        }
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return extratoList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = extratoList[(indexPath as NSIndexPath).row]
        
        if item.valor! < 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "pagamentoCell", for: indexPath) as! ExtratoCell
            cell.dateLabel.text = formatarData(data: item.data!)
            cell.descriptionLabel.text = item.descricao
            cell.typeLabel.text = "Pagamento"
            cell.valueLabel.text = formatarValor(valor: item.valor!)
        
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "recebimentoCell", for: indexPath) as! ExtratoCell
            cell.dateLabel.text = formatarData(data: item.data!)
            cell.descriptionLabel.text = item.descricao
            cell.typeLabel.text = "Recebimento"
            cell.valueLabel.text = formatarValor(valor: item.valor!)
            
            return cell
        }
    }
}

extension HomeViewController: ExtratoServiceDelegate {
    func extratoSuccess(extratoList: [Extrato]) {
        DispatchQueue.main.async {
            self.extratoList = extratoList
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    
    func extratoError(message: String) {
        SVProgressHUD.dismiss()
        print(message)
    }
}
