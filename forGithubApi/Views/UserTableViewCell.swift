//
//  UserTableViewCell.swift
//  forGithubApi
//
//  Created by Andriy Kruglyanko on 11/25/18.
//  Copyright © 2018 andriyKruglyanko. All rights reserved.
//

import UIKit

protocol ChooseDelegate{
    func chooseClick(tag:Int, userId: Int64)
}

class UserTableViewCell: UITableViewCell {
    var delegateChoose:ChooseDelegate?
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    var chosen: Bool = false
    var curCellIndex: IndexPath = IndexPath()
    var curUser = User()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setWithUser(_ user: User) {
        curUser = user
        button.tag = curCellIndex.row
        if let value = user.name {
            nameLabel.text = value
        }
        if let value = user.url_details {
            let fullNameArr = value.components(separatedBy: "/")
            let l = fullNameArr.last
            urlLabel.text = l
        }
        if user.chosen {
            button.setImage(UIImage(named:"selected"), for: .normal)
            chosen = true
        } else {
            button.setImage(UIImage(named:"notSelected"), for: .normal)
            chosen = false
        }
        self.layoutIfNeeded()
    }
    
    @IBAction func chosenClicked(_ sender: Any) {
        if self.delegateChoose != nil {
            print("delegateChoose tag = \(button.tag)")
            if curUser.chosen {
                button.setImage(UIImage(named:"notSelected"), for: .normal)
                chosen = false
            } else {
                button.setImage(UIImage(named:"selected"), for: .normal)
                chosen = true
            }
            delegateChoose?.chooseClick(tag: button.tag, userId: curUser.id)
            
        }
    }
    
    
}
