import CoreBluetooth
import UIKit

class ViewController: UIViewController, UITableViewDelegate {
var centralManager: CBCentralManager?
var peripherals = Array<CBPeripheral>()


    @IBOutlet weak var tableView: UITableView!

override func viewDidLoad() {
super.viewDidLoad()
    self.tableView.register(UITableViewCell.self, forCellReuseIdentifier:"cell")
    self.tableView.dataSource=self
    self.tableView.delegate=self
//Initialise CoreBluetooth Central Manager
centralManager = CBCentralManager(delegate: self, queue: DispatchQueue.main)

}
}

extension ViewController: CBCentralManagerDelegate {
func centralManagerDidUpdateState(_ central: CBCentralManager) {
if (central.state == .poweredOn){
    //let kServiceUUID="B9407F30-F5F8-466E-AFF9-25556B57FE6D"
      let kServiceUUID="2E2ABC62-8036-4E8E-99ED-8B841C45E507"

    let serviceUUID = CBUUID(string: kServiceUUID)
    self.log(.debug, msg: "UUID:::: \(serviceUUID)")
    //let cbuuidArray = [serviceUUID]
self.centralManager?.scanForPeripherals(withServices: [serviceUUID], options: nil)
}
else {
// do something like alert the user that ble is not on
}
}

func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
peripherals.append(peripheral)
tableView.reloadData()
}
}

extension ViewController: UITableViewDataSource {
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell

let peripheral = peripherals[indexPath.row]
    cell.textLabel?.text = peripheral.identifier.uuidString

return cell
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
return peripherals.count
}
}
