//
//  SelectedUserCollectionViewCell.swift
//  forGithubApi
//
//  Created by Andriy Kruglyanko on 11/25/18.
//  Copyright © 2018 andriyKruglyanko. All rights reserved.
//

import UIKit

protocol DeleteDelegate{
    func deleteClick(tag:Int, userId: Int64)
}

protocol DeleteSecondScreenDelegate{
    func deleteClick(tag:Int, userId: Int64)
}

class SelectedUserCollectionViewCell: UICollectionViewCell {
    var delegateDelete:DeleteDelegate?
    var delegateSecondScreenDelete:DeleteSecondScreenDelegate?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var butonDelete: UIButton!
    var curCellIndex: IndexPath = IndexPath()
    var curUser = User()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    func setWithUser(_ user: User) {
        curUser = user
        butonDelete.tag = curCellIndex.row
        if let value = user.name {
            nameLabel.text = value
        } else {
            nameLabel.text = "no name"
        }
        if let _ = user.avatar_url {
            
        } else {
            avatarImageView.image = UIImage(named:"noAvatar")
        }
        self.layoutIfNeeded()
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        if self.delegateDelete != nil {
            print("delegateChoose tag = \(butonDelete.tag)")
            delegateDelete?.deleteClick(tag: butonDelete.tag, userId: curUser.id)
            
        }
        if self.delegateSecondScreenDelete != nil {
            print("delegateSecondScreenDelete tag = \(butonDelete.tag)")
            delegateSecondScreenDelete?.deleteClick(tag: butonDelete.tag, userId: curUser.id)
            
        }
    }
    
    
    
}
