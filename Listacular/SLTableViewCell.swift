//
//  SLTableViewCell.swift
//  Listacular
//
//  Created by Will Zimmer on 12/15/15.
//  Copyright © 2015 Will Zimmer. All rights reserved.
//

import UIKit
import CoreData

protocol SLTableCellDelegate {
    func cellButtonTapped(cell: SLTableViewCell)
}

class SLTableViewCell: UITableViewCell {

    //delegate variable
    var delegate: SLTableCellDelegate?
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var cellLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonTapped(sender: AnyObject) {
        //call delegate method
        delegate?.cellButtonTapped(self)
    }

}
