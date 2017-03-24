//
//  ListInterfaceController.swift
//  watch Extension
//
//  Created by Diogo on 18/03/17.
//  Copyright © 2017 Diogo Tridapalli. All rights reserved.
//

import WatchKit
import Foundation


class ListInterfaceController: WKInterfaceController {

    @IBOutlet var massInterfaceLabel: WKInterfaceLabel!

    @IBOutlet var mainGroup: WKInterfaceGroup!
    @IBOutlet var notRequestedGroup: WKInterfaceGroup!
    @IBOutlet var deniedGroup: WKInterfaceGroup!

    let massRepository: MassService = MassService()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        massInterfaceLabel.setText("Loading ...")
    }
    
    override func willActivate() {

        switch massRepository.authorizationStatus {
        case .authorized:
            loadCurrentMass()
            mainGroup.setHidden(false)
            notRequestedGroup.setHidden(true)
            deniedGroup.setHidden(true)
        case .notDetermined:
            mainGroup.setHidden(true)
            notRequestedGroup.setHidden(false)
            deniedGroup.setHidden(true)
            massRepository.requestAuthorization() { print($0) }
        case .denied:
            mainGroup.setHidden(true)
            notRequestedGroup.setHidden(true)
            deniedGroup.setHidden(false)
        }

        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func loadCurrentMass() {
        massRepository.fetch(entries: 1) { samples in
            if let mass = samples.first {
                let massFormatter = MeasurementFormatter()
                massFormatter.numberFormatter.minimumFractionDigits = 1
                massFormatter.numberFormatter.maximumFractionDigits = 1
                massFormatter.unitOptions = .providedUnit

                self.massInterfaceLabel.setText(massFormatter.string(from: mass.value))
            } else {
                self.massInterfaceLabel.setText("No entry")
            }
        }
    }

    @IBAction func addMassAction() {
        pushController(withName: "add", context: nil)
    }

}
