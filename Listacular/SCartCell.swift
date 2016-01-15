//
//  SCartCell.swift
//  Listacular
//
//  Created by Will Zimmer on 1/15/16.
//  Copyright © 2016 Will Zimmer. All rights reserved.
//

import UIKit

protocol SCartCellDelegate {
    func cellButtonTapped(cell: SCartCell)
}

class SCartCell: UITableViewCell {
    
    //delegate variable
    var delegate: SCartCellDelegate?
    
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
