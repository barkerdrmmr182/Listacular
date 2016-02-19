//
//  MealPlanningCell.swift
//  Listacular
//
//  Created by Will Zimmer on 2/8/16.
//  Copyright © 2016 Will Zimmer. All rights reserved.
//

import UIKit

protocol MealTableCellDelegate {
    func cellButtonTapped(cell: MealPlanningCell)
}

class MealPlanningCell: UITableViewCell {

    //delegate variable
    var delegate: MealTableCellDelegate?

    @IBOutlet weak var cellButton: UIView!
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
