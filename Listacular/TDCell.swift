//
//  TDCell.swift
//  Listacular
//
//  Created by Will Zimmer on 1/15/16.
//  Copyright © 2016 Will Zimmer. All rights reserved.
//

import UIKit

protocol TDCellDelegate {
    func cellButtonTapped(cell: TDCell)
}

class TDCell: UITableViewCell {
    
    //delegate variable
    var delegate: TDCellDelegate?
    
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
