//
//  SearchCompletionTableViewCell.swift
//  MapKitSearchView
//
//  Created by Philip on 10/11/18.
//  Copyright © 2018 Next Generation. All rights reserved.
//

import MapKit
import UIKit

public class SearchCompletionTableViewCell: UITableViewCell {
    func viewSetup(withSearchCompletion searchCompletion: MKLocalSearchCompletion) {
        let attributedString = NSMutableAttributedString(string: searchCompletion.title)
        for highlightRange in searchCompletion.titleHighlightRanges {
            attributedString.addAttribute(
                NSAttributedString.Key.font,
                value: UIFont.boldSystemFont(ofSize: textLabel?.font.pointSize ?? 14),
                range: highlightRange.rangeValue)
        }
        textLabel?.attributedText = attributedString
        
        let attributedStringDetail = NSMutableAttributedString(string: searchCompletion.subtitle)
        for highlightRange in searchCompletion.subtitleHighlightRanges {
            attributedStringDetail.addAttribute(
                NSAttributedString.Key.font,
                value: UIFont.boldSystemFont(ofSize: detailTextLabel?.font.pointSize ?? 13),
                range: highlightRange.rangeValue)
        }
        detailTextLabel?.attributedText = attributedStringDetail
    }
}
