//
//  TableViewCell.swift
//  PropertyList APP
//
//  Created by Droisys on 26/08/25.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var myImageView: UIImageView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        myImageView.applyCardStyle(
            cornerRadius: 15,
            borderWidth: 2,
            borderColor: .systemBlue,
            shadowColor: .black,
            shadowOpacity: 0.2,
            shadowRadius: 5.0,
            shadowOffset: .zero
        )
    }
    // Initialization code
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        //Configure the view for the selected state
    }
}

extension UIImageView {
    
    func applyCardStyle(
        cornerRadius: CGFloat = 15,
        borderWidth: CGFloat = 2,
        borderColor: UIColor = .systemBlue,
        shadowColor: UIColor = .black,
        shadowOpacity: Float = 0.5,
        shadowRadius: CGFloat = 5.0,
        shadowOffset: CGSize = .zero // shadow 4 side par ave
    ) {
        
        // Border
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
        clipsToBounds = true   // for image round
        
        // add shadow layer saperately
        if let superlayer = superview?.layer {
            let shadowLayer = CALayer()
            shadowLayer.frame = frame
            shadowLayer.cornerRadius = cornerRadius
            
            shadowLayer.shadowColor = shadowColor.cgColor
            shadowLayer.shadowOpacity = shadowOpacity
            shadowLayer.shadowRadius = shadowRadius
            shadowLayer.shadowOffset = shadowOffset
            shadowLayer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
            
            // shadow put bottom in image
            superlayer.insertSublayer(shadowLayer, below: layer)
        }
    }
}
